defmodule ElixirPopularity.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_popularity,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirPopularity.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1.2"},
      {:httpoison, "~> 1.6.1"},
      {:broadway, "~> 0.4.0"},
      {:broadway_rabbitmq, "~> 0.4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:gen_rmq, "~> 2.3.0"}
    ]
  end
end
