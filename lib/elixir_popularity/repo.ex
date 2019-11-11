defmodule ElixirPopularity.Repo do
  use Ecto.Repo,
    otp_app: :elixir_popularity,
    adapter: Ecto.Adapters.Postgres
end
