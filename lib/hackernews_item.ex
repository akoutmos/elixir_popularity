defmodule ElixirPopularity.HackernewsItem do
  alias __MODULE__

  defstruct text: nil, type: nil, title: nil, time: nil

  def create(text, type, title, unix_time) do
    %HackernewsItem{
      text: text,
      type: type,
      title: title,
      time: get_date_time(unix_time)
    }
  end

  defp get_date_time(nil), do: nil

  defp get_date_time(unix_time) do
    {:ok, date_time} = DateTime.from_unix(unix_time)

    DateTime.to_date(date_time)
  end
end
