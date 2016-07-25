use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gist_grouper, GistGrouper.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :gist_grouper, GistGrouper.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "gist_grouper_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
