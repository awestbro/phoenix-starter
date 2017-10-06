defmodule MyAppWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import MyAppWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint MyAppWeb.Endpoint

      def authenticated_connection(user, token \\ :token, opts \\ []) do
        build_conn()
        |> bypass_through(MyApp.Router, [:browser])
        |> get("/")
        |> Map.update!(:state, fn (_) -> :set end)
        |> Guardian.Plug.sign_in(user, token, opts)
        |> Plug.Conn.send_resp(200, "Flush the session")
        |> recycle
      end

      def authenticated_json_connection(user, token \\ :token, opts \\ []) do
        {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
        build_conn()
        |> bypass_through(MyApp.Router, [:api])
        |> get("/")
        |> Plug.Conn.send_resp(200, "Flush the session")
        |> recycle
        |> put_req_header("authorization", "Bearer #{jwt}")
      end
    end
  end


  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyApp.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, {:shared, self()})
    end
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

end
