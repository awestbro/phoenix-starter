defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # plug Guardian.Plug.VerifySession
    # plug Guardian.Plug.LoadResource
    plug MyAppWeb.Guardian.AuthBrowserPipeline
    plug MyAppWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    # plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    # plug Guardian.Plug.LoadResource
    plug MyAppWeb.Guardian.AuthApiPipeline
    plug MyAppWeb.Auth
  end

  scope "/", MyAppWeb do
    pipe_through :browser
    # Index
    get "/", PageController, :index
    # Users/ Registration
    resources "/users", UserController
    # Accounts
    get "/accounts/:id/activation", AccountController, :show_activation_status
    get "/accounts/:id/activation/resend", AccountController, :resend_activation
    get "/accounts/:id/activation/:activation_token", AccountController, :activate
    get "/accounts/password/reset", AccountController, :show_reset_password
    post "/accounts/password/reset", AccountController, :send_password_reset_email
    get "/accounts/password/reset/:id/:reset_token", AccountController, :show_password_change
    post "/accounts/password/reset/:id", AccountController, :reset_password
    # Sessions
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyAppWeb do
  #   pipe_through :api
  # end
end
