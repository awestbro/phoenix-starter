use Mix.Config


# General application configuration
config :myapp,
  reset_password_interval_ms: 250

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :myapp, MyAppWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :myapp, MyApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "myapp_test",
  hostname: if(System.get_env("CI"), do: "postgres", else: "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox

config :myapp, MyApp.Mailer,
  adapter: Bamboo.TestAdapter
