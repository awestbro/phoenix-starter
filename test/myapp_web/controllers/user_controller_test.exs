defmodule MyAppWeb.UserControllerTest do
  use MyAppWeb.ConnCase
  use Bamboo.Test

  alias MyApp.Accounts
  alias MyApp.Accounts.User

  @create_attrs %{email: "some@email.com", password_hash: "some password_hash", password: "test", password_confirmation: "test", type: User.types().user, username: "some username", activated: true}
  @update_attrs %{email: "some@updatedemail.com", password_hash: "some updated password_hash", type: User.types().user, username: "some updated username"}
  @invalid_attrs %{email: nil, password_hash: nil, type: User.types().user, username: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get conn, user_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get conn, user_path(conn, :new)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to activation status when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      id = conn.assigns.current_user.id
      assert redirected_to(conn) == account_path(conn, :show_activation_status, id)
    end

    test "assigns activation token to user", %{conn: conn} do
      post conn, user_path(conn, :create), user: @create_attrs
      user = Accounts.get_user_by_email!(@create_attrs.email)
      assert user.activation_token != nil
      assert user.activated == false
    end

    # TODO: Reimplement in activation test
    test "attaches set-cookie to the response and assigns a user to the connection", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      assert conn.assigns.current_user
      assert conn.assigns.current_user.activated == false
      assert Map.has_key?(conn.resp_cookies, "_myapp_key")
    end

    test "sends an activation email", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      user = Accounts.get_user_by_email!(@create_attrs.email)
      assert_delivered_email MyApp.Email.activation_email(conn, user)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "New User"
    end

    test "renders errors when passwords do not match", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: Map.merge(@create_attrs, %{ password: "test", password_confirmation: "testwoops" })
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{user: user} do
      conn = authenticated_connection(user)
      conn = get conn, user_path(conn, :edit, user)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{user: user} do
      conn = authenticated_connection(user)
      conn = put conn, user_path(conn, :update, user), user: @update_attrs
      assert redirected_to(conn) == user_path(conn, :show, user)

      conn = authenticated_connection(user)
      conn = get conn, user_path(conn, :show, user)
      assert html_response(conn, 200) =~ "some updated username"
    end

    test "renders errors when data is invalid", %{user: user} do
      conn = authenticated_connection(user)
      conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{user: user} do
      conn = authenticated_connection(user)
      conn = delete conn, user_path(conn, :delete, user)
      assert redirected_to(conn) == user_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, user_path(conn, :show, user)
      end
    end

    test "fails when conn is not the user", %{user: user} do
      {:ok, bad_user} = Accounts.create_user(Map.merge(@create_attrs, %{ email: "baduser@test.com", username: "ayy", password: "lmaooo", password_confirmation: "lmaooo" }))
      conn = authenticated_connection(bad_user)
      conn = delete conn, user_path(conn, :delete, user)
      assert redirected_to(conn) == page_path(conn, :index)
      assert Map.get(conn.private, :phoenix_flash) == %{"error" => "You are not authorized to do that!"}
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
