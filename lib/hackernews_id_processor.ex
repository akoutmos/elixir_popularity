defmodule ElixirPopularity.HackernewsIdProcessor do
  use Broadway

  alias Broadway.Message
  alias ElixirPopularity.{HackernewsApi, RMQPublisher}

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producers: [
        default: [
          module:
            {BroadwayRabbitMQ.Producer,
             queue: RMQPublisher.item_id_queue_name(),
             connection: [
               username: "rabbitmq",
               password: "rabbitmq"
             ]},
          stages: 1
        ]
      ],
      processors: [
        default: [
          stages: 100
        ]
      ],
      batchers: [
        default: [
          batch_size: 10,
          batch_timeout: 10_000,
          stages: 2
        ]
      ]
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    Message.update_data(message, fn hn_id ->
      {hn_id, HackernewsApi.get_hn_item(hn_id)}
    end)
  end

  @impl true
  def handle_batch(_batcher, messages, _batch_info, _context) do
    encoded_payload =
      messages
      |> Enum.reject(fn
        %Message{data: {_id, :error}} -> true
        _ -> false
      end)
      |> Enum.map(fn %Message{data: {id, item}} ->
        %{
          id: id,
          item: Map.from_struct(item)
        }
      end)
      |> Jason.encode!()

    RMQPublisher.publish_hn_items(encoded_payload)

    messages
  end
end
