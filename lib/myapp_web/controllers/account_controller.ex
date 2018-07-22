defmodule MyAppWeb.AccountController do
  use MyAppWeb, :controller

  alias MyApp.Accounts
  alias MyApp.Accounts.User
  alias MyApp.Mailer
  alias MyApp.Email

  def show_activation_status(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "activation_status.html", user: user)
  end

  def resend_activation(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    cond do
      user.activated ->
        conn
        |> put_flash(:error, "That account is already activated")
        |> redirect(to: page_path(conn, :index))
      user.activation_attempts > Application.get_env(:myapp, :email_activation_max) ->
        conn
        |> put_flash(:error, "Activation email has been sent too many times. Please contact support to resolve this issue.")
        |> redirect(to: account_path(conn, :show_activation_status, user.id))
      !user.activated ->
        Accounts.update_user(user, %{activation_attempts: user.activation_attempts + 1})
        conn
        |> Email.activation_email(user)
        |> Mailer.deliver_now
        conn
        |> put_flash(:info, "Activation email sent!")
        |> redirect(to: account_path(conn, :show_activation_status, user.id))
      true ->
        conn
        |> redirect(to: page_path(conn, :index))
    end
  end

  def activate(conn, %{"id" => id, "activation_token" => activation_token}) do
    user = Accounts.get_user!(id)
    if user.activation_token != activation_token do
      conn
      |> put_flash(:error, "Sorry! We couldn't activate your account with that information")
      |> redirect(to: account_path(conn, :show_activation_status, user.id))
    else
      Accounts.update_user(user, %{activation_token: nil, activated: true})
      user = Accounts.get_user!(id)
      conn
      |> MyAppWeb.Auth.login(user)
      |> put_flash(:info, "Welcome to MyApp!")
      |> redirect(to: page_path(conn, :index))
    end
  end

  def show_reset_password(conn, _params) do
    conn
    |> render("password_reset_get_email.html")
  end

  defp can_reset_password(nil), do: true
  defp can_reset_password(time) do
    duration = -Application.get_env(:myapp, :reset_password_interval_ms)
    Timex.before?(time, Timex.to_naive_datetime(Timex.shift(Timex.now, milliseconds: duration)))
  end

  def send_password_reset_email(conn, %{"email_params" => %{"email" => email}}) do
    user = Accounts.get_user_by_email(email)
    cond do
      user && can_reset_password(user.last_password_reset_attempt) ->
        user = Accounts.update_user!(user, %{password_reset_token: UUID.uuid4(), last_password_reset_attempt: NaiveDateTime.utc_now()})
        conn
        |> MyApp.Email.reset_password_email(user)
        |> MyApp.Mailer.deliver_now
        conn
        |> put_flash(:info, "Password reset email sent!")
        |> redirect(to: page_path(conn, :index))
      user ->
        conn
        |> put_flash(:error, "Password reset email was recently sent. Please check your email or contact support if you are experiencing issues")
        |> redirect(to: account_path(conn, :show_reset_password))
      true ->
        conn
        |> put_flash(:error, "Could not find an account associated with that email")
        |> redirect(to: account_path(conn, :show_reset_password))
    end
  end

  def show_password_change(conn, %{"id" => id, "reset_token" => reset_token}) do
    user = Accounts.get_user!(id)
    if reset_token == user.password_reset_token do
      changeset = Accounts.change_user(%User{})
      conn
      |> render("show_password_change.html", changeset: changeset, reset_token: reset_token, user_id: id)
    else
      conn
      |> put_flash(:error, "The password reset token you provided does not match our records. Please contact support if you feel like this is an error")
      |> redirect(to: page_path(conn, :index))
    end
  end

  def reset_password(conn, %{"id" => id, "reset_params" => reset_params}) do
    user = Accounts.get_user!(id)
    reset_token = reset_params["password_reset_token"]
    cond do
      user.password_reset_token == nil ->
        conn
        |> put_flash(:error, "The password reset token you provided does not match our records. Please contact support if you feel like this is an error")
        |> redirect(to: page_path(conn, :index))
      reset_token == user.password_reset_token ->
        case Accounts.change_user_password(user, reset_params) do
          {:ok, _} ->
            Accounts.update_user!(user, %{password_reset_token: nil, last_password_reset_attempt: nil})
            conn
            |> put_flash(:info, "Password successfully changed!")
            |> redirect(to: page_path(conn, :index))
          {:error, changeset} ->
            conn
            |> render("show_password_change.html", changeset: changeset, reset_token: reset_token, user_id: id)
        end
      true ->
        conn
        |> put_flash(:error, "The password reset token you provided does not match our records. Please contact support if you feel like this is an error")
        |> redirect(to: page_path(conn, :index))
    end
  end

end
