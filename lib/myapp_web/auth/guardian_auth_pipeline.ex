defmodule MyAppWeb.Guardian.AuthBrowserPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline, otp_app: :myapp,
                              module: MyAppWeb.Guardian,
                              error_handler: MyAppWeb.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.LoadResource, allow_blank: true
end

defmodule MyAppWeb.Guardian.AuthApiPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline, otp_app: :myapp,
                              module: MyAppWeb.Guardian,
                              error_handler: MyAppWeb.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, claims: @claims
  plug Guardian.Plug.LoadResource
end
