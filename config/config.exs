# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :myapp,
  ecto_repos: [MyApp.Repo],
  email_activation_max: 5,
  # 20 minutes
  reset_password_interval_ms: 1_200_000

# Configures the endpoint
config :myapp, MyAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/ZcINUEmABGYtbGFXtJ6mubK6RAkWggqu0w3zh1pOgxCZuYszDoSDLnYgoOjek67",
  render_errors: [view: MyAppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MyApp.PubSub, adapter: Phoenix.PubSub.PG2]

config :myapp, MyApp.Mailer, adapter: Bamboo.LocalAdapter

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :myapp, MyAppWeb.Guardian,
  allower_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "myapp",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: "AyyylmaoImASecrett"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
