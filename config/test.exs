import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :campus_chat, CampusChat.Repo,
  username: "postgres",
  password: "root",
  database: "campus_chat_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :campus_chat, CampusChat.CampusRepo,
  username: "postgres",
  password: "root",
  database: "campus",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :campus_chat, CampusChatWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "vz/oV8Og+mrwetjxzQ1HkrTo19LJnjP+DetDwMsUpARl6IACcQVViCidqHFR37zb",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
