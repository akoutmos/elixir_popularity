defmodule ElixirPopularity.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      :hackney_pool.child_spec(:hn_id_pool, timeout: 15000, max_connections: 100),
      ElixirPopularity.Repo,
      %{
        id: ElixirPopularity.RMQPublisher,
        start: {ElixirPopularity.RMQPublisher, :start_link, []}
      },
      %{
        id: ElixirPopularity.HackerNewsIdGenerator,
        start:
          {ElixirPopularity.HackerNewsIdGenerator, :start_link,
           [
             %{
               current_id: 2_306_006,
               end_id: 21_672_858,
               generate_threshold: 50_000,
               batch_size: 30_000,
               poll_rate: 30_000
             }
           ]},
        restart: :transient
      },
      ElixirPopularity.HackernewsIdProcessor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirPopularity.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
