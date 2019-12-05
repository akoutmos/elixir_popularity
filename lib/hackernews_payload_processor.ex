defmodule ElixirPopularity.HackernewsPayloadProcessor do
  use Broadway

  alias Broadway.Message
  alias ElixirPopularity.{HNStats, Repo}

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producers: [
        default: [
          module:
            {BroadwayRabbitMQ.Producer,
             queue: ElixirPopularity.RMQPublisher.bulk_item_data_queue_name(),
             connection: [
               username: "rabbitmq",
               password: "rabbitmq"
             ]},
          stages: 1
        ]
      ],
      processors: [
        default: [
          stages: 20
        ]
      ]
    )
  end

  def handle_message(_processor, %Message{data: data} = message, _context) do
    data
    |> Jason.decode!()
    |> Enum.map(fn entry ->
      summarize_data(entry)
    end)
    |> Enum.filter(fn summary ->
      summary.language_present
      |> Map.values()
      |> Enum.member?(true)
    end)
    |> Enum.each(fn entry ->
      date = entry.date
      hn_id = entry.id
      type = entry.type

      Enum.each(entry.language_present, fn
        {lang, true} ->
          %HNStats{}
          |> HNStats.changeset(%{
            item_id: hn_id,
            item_type: type,
            language: Atom.to_string(lang),
            date: date,
            occurances: 1
          })
          |> Repo.insert()

        {_lang, false} ->
          nil
      end)
    end)

    message
  end

  defp summarize_data(hn_item) do
    %{
      id: hn_item["id"],
      date: hn_item["item"]["time"],
      type: hn_item["item"]["type"],
      language_present: language_check(hn_item["item"])
    }
  end

  defp language_check(%{"type" => "story", "text" => text}) when not is_nil(text) do
    process_text(text)
  end

  defp language_check(%{"type" => "story", "title" => text}) when not is_nil(text) do
    process_text(text)
  end

  defp language_check(%{"type" => "comment", "text" => text}) when not is_nil(text) do
    process_text(text)
  end

  defp language_check(%{"type" => "job", "text" => text}) when not is_nil(text) do
    process_text(text)
  end

  defp process_text(text) do
    [elixir: ~r/elixir/i, erlang: ~r/erlang/i]
    |> Enum.map(fn {lang, regex} ->
      {lang, String.match?(text, regex)}
    end)
    |> Map.new()
  end

  defp language_check(_item) do
    %{
      elixir: 0,
      erlang: 0
    }
  end
end
