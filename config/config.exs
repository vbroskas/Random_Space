# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :space,
  ecto_repos: [Space.Repo]

# Configures the endpoint
config :space, SpaceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QWGvMF782dEwg7aZp1ZbE87bf0axx/7eJGneAtNDvSpofqU+COkTgTGqKOp1kMfy",
  render_errors: [view: SpaceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Space.PubSub,
  live_view: [signing_salt: "J/mpKfc8"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
