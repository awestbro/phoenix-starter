defmodule MyAppWeb.SessionControllerTest do
  use MyAppWeb.ConnCase

  alias MyApp.Accounts.User

  def fixture(:user) do
    {:ok, user} = MyApp.Accounts.create_user(%{
      email: "unittest@test.com",
      password: "test",
      password_confirmation: "test",
      password_hash: "aasdfasdf",
      type: User.types().user,
      username: "unittestuser"
    })
    user
  end

  describe "new"  do
    test "renders form", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      assert html_response(conn, 200) =~ "Login"
    end
  end

  describe "create"  do
    setup [:create_user]

    test "logs in valid user", %{conn: conn} do
      conn = post conn, session_path(conn, :create, %{"session" => %{username: "unittestuser", password: "test"}})
      assert redirected_to(conn) == page_path(conn, :index)
      assert conn.assigns.current_user
    end

    test "rejects invalid credentials", %{conn: conn} do
      conn = post conn, session_path(conn, :create, %{"session" => %{username: "unittestuser", password: "wrongpw"}})
      assert html_response(conn, 200) =~ "Invalid"
      assert conn.assigns.current_user == nil
    end
  end

  describe "delete"  do
    setup [:create_user]

    test "logs a user out", %{conn: conn, user: user} do
      conn = post conn, session_path(conn, :create, %{"session" => %{username: "unittestuser", password: "test"}})
      conn = delete conn, session_path(conn, :delete, user)
      assert redirected_to(conn) == page_path(conn, :index)
      assert conn.private.guardian_default_resource == nil
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
