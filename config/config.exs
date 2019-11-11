use Mix.Config

config :elixir_popularity, ecto_repos: [ElixirPopularity.Repo]

config :elixir_popularity, ElixirPopularity.Repo,
  database: "elixir_popularity_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  log: false

config :logger, :console, format: "[$level] $message\n"
