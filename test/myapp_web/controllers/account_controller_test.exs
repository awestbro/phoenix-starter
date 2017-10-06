defmodule MyAppWeb.AccountControllerTest do
  use MyAppWeb.ConnCase
  use Bamboo.Test

  alias MyApp.Accounts
  alias MyApp.Accounts.User

  @create_attrs %{email: "some@email.com", password_hash: Comeonin.Bcrypt.hashpwsalt("test"), password: "test", password_confirmation: "test", type: User.types().user, username: "some username", activated: true}

  describe "activate" do
    test "activates account and logs in user on success", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      user = Accounts.get_user_by_email!(@create_attrs.email)
      conn = get conn, account_path(conn, :activate, user.id, user.activation_token)
      assert conn.assigns.current_user.activated
      assert redirected_to(conn) == page_path(conn, :index)
    end

    test "returns error on wrong token", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      user = Accounts.get_user_by_email!(@create_attrs.email)
      conn = get conn, account_path(conn, :activate, user.id, "wrong_token_lol")
      assert conn.assigns.current_user.activated == false
      assert redirected_to(conn) == account_path(conn, :show_activation_status, user.id)
    end
  end

  describe "resend_activation" do
    test "redirects to index if account is already valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      user = Accounts.get_user_by_email!(@create_attrs.email)
      conn = get conn, account_path(conn, :activate, user.id, user.activation_token)
      conn = get conn, account_path(conn, :resend_activation, user.id)
      assert redirected_to(conn) == page_path(conn, :index)
      assert conn.assigns.current_user.activated == true
    end

    test "errors if the account has too many activation attempts", %{conn: conn} do
      max_attempts = Application.get_env(:myapp, :email_activation_max)
      conn = post conn, user_path(conn, :create), user: @create_attrs
      user = Accounts.get_user_by_email!(@create_attrs.email)
      for _ <- 1..max_attempts + 1, do: get conn, account_path(conn, :resend_activation, user.id)
      conn = get conn, account_path(conn, :resend_activation, user.id)
      assert redirected_to(conn) == account_path(conn, :show_activation_status, user.id)
      assert get_flash(conn, :error) =~ "too many"
    end

    test "sends the activation if user is not activated", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      user = Accounts.get_user_by_email!(@create_attrs.email)
      conn = get conn, account_path(conn, :resend_activation, user.id)
      user = Accounts.get_user_by_email!(@create_attrs.email)
      assert redirected_to(conn) == account_path(conn, :show_activation_status, user.id)
      assert_delivered_email MyApp.Email.activation_email(conn, user)
    end
  end

  describe "show_activation_status" do
    test "shows email has been sent if not activated", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      user = Accounts.get_user_by_email!(@create_attrs.email)
      conn = get conn, account_path(conn, :show_activation_status, user.id)
      assert html_response(conn, 200) =~ "An activation email has been sent"
    end

    test "shows account is already activated", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      user = Accounts.get_user_by_email!(@create_attrs.email)
      conn = get conn, account_path(conn, :activate, user.id, user.activation_token)
      conn = get conn, account_path(conn, :show_activation_status, user.id)
      assert html_response(conn, 200) =~ "already active"
    end
  end

  describe "show_reset_password" do
    test "should display an html form", %{conn: conn} do
      conn = get conn, account_path(conn, :show_reset_password)
      assert html_response(conn, 200) =~ "Forgotten Password"
    end
  end

  describe "send_password_reset_email" do
    setup [:create_user]

    test "should send a reset email with valid credentials", %{conn: conn, user: user} do
      conn = post conn, account_path(conn, :send_password_reset_email, %{"email_params" => %{"email" => user.email}})
      user = Accounts.get_user_by_email!(user.email)
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :info) =~ "reset email sent!"
      assert_delivered_email MyApp.Email.reset_password_email(conn, user)
    end

    test "should show error if no email matches", %{conn: conn} do
      conn = post conn, account_path(conn, :send_password_reset_email, %{"email_params" => %{"email" => "notme@heckoff.com"}})
      assert redirected_to(conn) == account_path(conn, :show_reset_password)
      assert get_flash(conn, :error) =~ "Could not find"
    end

    test "should error if an email has been sent recently", %{conn: conn, user: user} do
      conn = post conn, account_path(conn, :send_password_reset_email, %{"email_params" => %{"email" => user.email}})
      conn = post conn, account_path(conn, :send_password_reset_email, %{"email_params" => %{"email" => user.email}})
      assert redirected_to(conn) == account_path(conn, :show_reset_password)
      assert get_flash(conn, :error) =~ "Password reset email was recently sent"
    end

    test "should allow reset email to be sent after wait period", %{conn: conn, user: user} do
      conn = post conn, account_path(conn, :send_password_reset_email, %{"email_params" => %{"email" => user.email}})
      wait_time = Application.get_env(:myapp, :reset_password_interval_ms)
      :timer.sleep(wait_time)
      conn = post conn, account_path(conn, :send_password_reset_email, %{"email_params" => %{"email" => user.email}})
      user = Accounts.get_user_by_email!(user.email)
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :info) =~ "reset email sent!"
      assert_delivered_email MyApp.Email.reset_password_email(conn, user)
    end
  end

  describe "show_password_change" do
    setup [:create_user]

    test "should display the reset form if reset tokens match", %{conn: conn, user: user} do
      conn = post conn, account_path(conn, :send_password_reset_email, %{"email_params" => %{"email" => user.email}})
      user = Accounts.get_user_by_email!(user.email)
      conn = get conn, account_path(conn, :show_password_change, user.id, user.password_reset_token)
      assert html_response(conn, 200) =~ "Reset Password"
    end

    test "should error if wrong token passed in", %{conn: conn, user: user} do
      conn = post conn, account_path(conn, :send_password_reset_email, %{"email_params" => %{"email" => user.email}})
      user = Accounts.get_user_by_email!(user.email)
      conn = get conn, account_path(conn, :show_password_change, user.id, UUID.uuid4())
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :error) =~ "reset token"
    end
  end

  describe  "reset_password" do
    setup [:create_user]

    test "should reset password on valid attempt", %{conn: conn, user: user} do
      conn = post conn, account_path(conn, :send_password_reset_email, %{"email_params" => %{"email" => user.email}})
      user = Accounts.get_user_by_email!(user.email)
      new_pw = "newvalidpw"
      conn = post conn, account_path(conn, :reset_password, user.id, %{"reset_params" => %{"password_reset_token" => user.password_reset_token, "password" => new_pw, "password_confirmation" => new_pw}})
      user = Accounts.get_user_by_email!(user.email)
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :info) =~ "Password successfully changed!"
      assert Comeonin.Bcrypt.checkpw(new_pw, user.password_hash)
      assert user.password_reset_token == nil
      assert user.last_password_reset_attempt == nil
    end

    test "should display errors if form fields are invalid", %{conn: conn, user: user} do
      conn = post conn, account_path(conn, :send_password_reset_email, %{"email_params" => %{"email" => user.email}})
      user = Accounts.get_user_by_email!(user.email)
      new_pw = "newvalidpw"
      bad_bw_confirm = "asdfsadfaf"
      conn = post conn, account_path(conn, :reset_password, user.id, %{"reset_params" => %{"password_reset_token" => user.password_reset_token, "password" => new_pw, "password_confirmation" => bad_bw_confirm}})
      user = Accounts.get_user_by_email!(user.email)
      assert html_response(conn, 200) =~ "not match"
      assert Comeonin.Bcrypt.checkpw(@create_attrs.password, user.password_hash)
    end

    test "should error if token does not match", %{conn: conn, user: user} do
      conn = post conn, account_path(conn, :send_password_reset_email, %{"email_params" => %{"email" => user.email}})
      user = Accounts.get_user_by_email!(user.email)
      new_pw = "newvalidpw"
      conn = post conn, account_path(conn, :reset_password, user.id, %{"reset_params" => %{"reset_token" => UUID.uuid4(), "password" => new_pw, "password_confirmation" => new_pw}})
      user = Accounts.get_user_by_email!(user.email)
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :error) =~ "reset token you provided does not match"
      assert Comeonin.Bcrypt.checkpw(@create_attrs.password, user.password_hash)
    end
  end

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    {:ok, user: user}
  end

end
