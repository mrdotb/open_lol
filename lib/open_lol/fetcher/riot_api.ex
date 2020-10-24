defmodule OpenLOL.Fetcher.RiotAPI do
  @soloq "420"
  @moduledoc """
  A module to interract with the riot API using Tesla library.

  How to use ?

      import OpenLOL.RiotAPI

      client = RiotAPI.client("euw1")
      result = client |> RiotAPI.summoner_by_name("1245124")

  See the official documentation for [riot api](https://developer.riotgames.com/api-methods/).
  """

  def summoner_by_account(client, encrypted_account_id) do
    Tesla.get(client, "/summoner/v4/summoners/by-account/" <> encrypted_account_id)
  end

  def summoner_by_name(_client, ""), do: {:error, "summoner_name is empty"}

  def summoner_by_name(client, summoner_name) do
    Tesla.get(
      client,
      "/summoner/v4/summoners/by-name/" <> URI.encode(summoner_name)
    )
  end

  def summoner_by_puuid(client, puuid) do
    Tesla.get(client, "/summoner/v4/summoners/by-puuid/" <> puuid)
  end

  def summoner_by_id(client, id) do
    Tesla.get(client, "/summoner/v4/summoners/" <> id)
  end

  def match_by_id(client, match_id) when is_number(match_id) do
    match_by_id(client, to_string(match_id))
  end

  def match_by_id(client, match_id) when is_binary(match_id) do
    Tesla.get(client, "/match/v4/matches/" <> match_id)
  end

  def matchlists_by_account(client, encrypted_account_id) do
    Tesla.get(
      client,
      "/match/v4/matchlists/by-account/" <> encrypted_account_id <> "?queue=" <> @soloq
    )
  end

  def timelines_by_match(client, match_id) do
    Tesla.get(client, "/match/v4/timelines/by-match/" <> match_id)
  end

  def client(platform) do
    module_config = Application.get_env(:open_lol, __MODULE__)

    middlewares = [
      {Tesla.Middleware.BaseUrl, "https://#{platform}.api.riotgames.com/lol"},
      Tesla.Middleware.JSON,
      Tesla.Middleware.Logger,
      {Tesla.Middleware.Retry,
       delay: 5_000,
       max_retries: 10,
       max_delay: 60_000,
       should_retry: fn
         {:ok, %{status: status}} when status in [429, 504] ->
           true

         {:ok, _} ->
           false

         {:error, _} ->
           true
       end},
      {Tesla.Middleware.Headers, [{"X-Riot-Token", module_config[:api_key]}]}
    ]

    Tesla.client(middlewares)
  end
end
