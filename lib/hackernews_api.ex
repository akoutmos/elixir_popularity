defmodule ElixirPopularity.HackernewsApi do
  @moduledoc """
  Fetches data from the Hackernews API, extracts the necessary fields,
  and massages some data
  """

  require Logger

  alias ElixirPopularity.HackernewsItem

  def get_hn_item(resource_id) do
    get_hn_item(resource_id, 4)
  end

  defp get_hn_item(resource_id, retry) do
    response =
      resource_id
      |> gen_api_url()
      |> HTTPoison.get([], hackney: [pool: :hn_id_pool])

    with {_, {:ok, body}} <- {"hn_api", handle_response(response)},
         {_, {:ok, decoded_payload}} <- {"payload_decode", Jason.decode(body)},
         {_, {:ok, data}} <- {"massage_data", massage_data(decoded_payload)} do
      data
    else
      {stage, error} ->
        Logger.warn(
          "Failed attempt #{5 - retry} at stage \"#{stage}\" with Hackernews ID of #{resource_id}. Error details: #{
            inspect(error)
          }"
        )

        if retry > 0 do
          get_hn_item(resource_id, retry - 1)
        else
          Logger.warn("Failed to retrieve Hackernews ID of #{resource_id}.")
          :error
        end
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_response({_, invalid_response}) do
    {:error, invalid_response}
  end

  defp gen_api_url(resource_id) do
    "https://hacker-news.firebaseio.com/v0/item/#{resource_id}.json"
  end

  defp massage_data(data) do
    {:ok,
     HackernewsItem.create(
       data["text"],
       data["type"],
       data["title"],
       data["time"]
     )}
  end
end
