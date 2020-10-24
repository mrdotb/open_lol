defmodule OpenLOL.MixProject do
  use Mix.Project

  def project do
    [
      app: :open_lol,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {OpenLOL.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:slugify, "~> 1.1"},
      {:ecto_sql, "~> 3.1"},
      {:floki, "~> 0.24.0"},
      {:gettext, "~> 0.11"},
      {:hackney, "~> 1.14.0"},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.4.9"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:tesla, "~> 1.3.0"},
      {:phoenix_inline_svg,
       git: "https://github.com/nikkomiu/phoenix_inline_svg",
       tag: "b920af17ab568a88b5493cd8d8651ba00e87dc3c"},

      # Test and dev dependencies
      {:credo, "~> 1.5.0-rc.2", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:git_hooks, "~> 0.5.0", only: [:test, :dev], runtime: false}
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
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
