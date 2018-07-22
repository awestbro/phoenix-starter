defmodule MyAppWeb.Auth do
  @claims %{typ: "access"}

  import Plug.Conn
  import Phoenix.Controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  def init([]), do: false

  def call(conn, _opts) do
    current_user = MyAppWeb.Guardian.Plug.current_resource(conn)
    assign(conn, :current_user, current_user)
  end

  def get_auth_error_message(conn) do
    cond do
      conn.assigns.current_user == nil ->
        "You must be logged in to perform that action"
      conn.assigns.current_user.activated == false ->
        "You must activate your account to perform that action"
      true ->
        "You must be logged in to perform that action"
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user && conn.assigns.current_user.activated do
      conn
    else
      case conn.private[:phoenix_pipelines] do
        [:api] ->
          conn
          |> put_status(403)
          |> json(%{error: get_auth_error_message(conn)})
          |> halt()
        [:browser] ->
          conn
          |> put_flash(:error, get_auth_error_message(conn))
          |> redirect(to: MyAppWeb.Router.Helpers.page_path(conn, :index))
          |> halt()
      end
    end
  end

  def login(conn, user) do
    conn
    |> MyAppWeb.Guardian.Plug.sign_in(user, @claims)
    |> assign(:current_user, user)
  end

  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(MyApp.Accounts.User, username: username)

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    MyAppWeb.Guardian.Plug.sign_out(conn)
  end

end
