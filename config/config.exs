# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :campus_chat,
  ecto_repos: [CampusChat.Repo, CampusChat.CampusRepo],
  unused_categories: ["Тестовый факультет", "Тестовое подразделение"],
  api_prefix: "/api"

# Configures the endpoint
config :campus_chat, CampusChatWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: CampusChatWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: CampusChat.PubSub,
  live_view: [signing_salt: "CpgO8YyJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Swagger config
config :campus_chat, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: CampusChatWeb.Router,     # phoenix routes will be converted to swagger paths
      endpoint: CampusChatWeb.Endpoint  # (optional) endpoint config used to set host, port and https schemes.
    ]
  }

config :phoenix_swagger, json_library: Jason

# CORS config
config :cors_plug,
  origin: ["http://localhost:4000", "http://localhost:8080"],
  credentials: true,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  headers: [
    "Authorization",
    "Content-Type",
    "Accept",
    "Origin",
    "User-Agent",
    "DNT",
    "Cache-Control",
    "X-Mx-ReqToken",
    "Keep-Alive",
    "X-Requested-With",
    "If-Modified-Since",
    "X-CSRF-Token",
    "Access-Control-Allow-Origin",
    "Access-Control-Allow-Methods",
    "Access-Control-Allow-Headers",
    "Set-Cookie"
  ],
  max_age: 1_728_000,
  send_preflight_response?: true


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
