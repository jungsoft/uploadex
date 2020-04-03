import Mix.Config

config :uploadex, ecto_repos: [Uploadex.Repo]

config :uploadex, Uploadex.Repo,
  database: "uploadex_text",
  hostname: "localhost",
  poolsize: 10,
  pool: Ecto.Adapters.SQL.Sandbox

config :ex_aws, :s3,
  access_key_id: "test",
  secret_access_key: "test"

config :logger, level: :info
