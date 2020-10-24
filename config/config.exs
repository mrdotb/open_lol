# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :open_lol,
  namespace: OpenLOL,
  ecto_repos: [OpenLOL.Repo]

# Configures the endpoint
config :open_lol, OpenLOLWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "j5hem5d4W+ZMXGPGKCK59g9t8XtzgGBrcswex1rQX9jSWJzjdHPiZBd01WHBFajQ",
  render_errors: [view: OpenLOLWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: OpenLOL.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Tesla config
# config :tesla, adapter: Tesla.Adapter.Hackney, ssl_options: [{:versions, [:'tlsv1.2']}]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
