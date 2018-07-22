defmodule MyApp.Mixfile do
  use Mix.Project

  def project do
    [
      app: :myapp,
      version: "0.0.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MyApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bamboo, "~> 1.0.0"},
      {:bcrypt_elixir, "~> 1.0.1"},
      {:comeonin, "~> 4.1.1"},
      {:cowboy, "~> 1.1.2"},
      {:credo, "~> 0.9.3", only: [:dev], runtime: false},
      {:gettext, "~> 0.15.0"},
      {:guardian, "~> 1.1.0"},
      {:httpoison, "~> 1.2.0"},
      {:phoenix, "~> 1.3.3"},
      {:phoenix_ecto, "~> 3.3.0"},
      {:phoenix_html, "~> 2.11.2"},
      {:phoenix_live_reload, "~> 1.1.5", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:postgrex, "~> 0.13.5"},
      {:timex, "~> 3.3.0"},
      {:uuid, "~> 1.1.7"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
