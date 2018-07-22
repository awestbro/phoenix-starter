defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller

  alias MyApp.Accounts
  alias MyApp.Accounts.User
  alias MyApp.Mailer
  alias MyApp.Email

  plug :authenticate_user when action in [:edit, :update, :delete]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    new_params = user_params
    |> Map.take(["username", "email", "password", "password_confirmation"])
    |> Map.merge(%{"type" => User.types().user, "activation_token" => UUID.uuid4(), "activated" => false})
    case Accounts.create_user(new_params) do
      {:ok, user} ->
        Email.activation_email(conn, user) |> Mailer.deliver_now
        conn
        |> MyAppWeb.Auth.login(user)
        |> redirect(to: account_path(conn, :show_activation_status, user.id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    # TODO: Make edit take only params that can be modified
    user = Accounts.get_user!(id)
    if can_modify_user?(conn, user) do
      changeset = Accounts.change_user(user)
      render(conn, "edit.html", user: user, changeset: changeset)
    else
      unauthorized(conn)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    if can_modify_user?(conn, user) do
      case Accounts.update_user(user, user_params) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "User updated successfully.")
          |> redirect(to: user_path(conn, :show, user))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", user: user, changeset: changeset)
      end
    else
      unauthorized(conn)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    if can_modify_user?(conn, user) do
      {:ok, _user} = Accounts.delete_user(user)
      conn
      |> put_flash(:info, "User deleted successfully.")
      |> redirect(to: user_path(conn, :index))
    else
      unauthorized(conn)
    end
  end

  def unauthorized(conn) do
    conn
    |> put_flash(:error, "You are not authorized to do that!")
    |> redirect(to: page_path(conn, :index))
  end

  def can_modify_user?(conn, user) do
    cond do
      conn.assigns.current_user.id == user.id ->
        true
      conn.assigns.current_user.type == User.types().admin ->
        true
      true ->
        false
    end
  end
end
