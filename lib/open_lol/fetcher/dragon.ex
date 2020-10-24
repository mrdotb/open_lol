defmodule OpenLOL.Fetcher.Dragon do
  @moduledoc """
  A module to interract with the riot ddragon assets.
  """

  @default_lang "en_US"

  def versions(client) do
    Tesla.get(client, "/versions.json")
  end

  def champions(client) do
    Tesla.get(client, "/champion.json")
  end

  def items(client) do
    Tesla.get(client, "/item.json")
  end

  def summoners(client) do
    Tesla.get(client, "/summoner.json")
  end

  def perks(client) do
    Tesla.get(client, "/runesReforged.json")
  end

  def client do
    middlewares = [
      {
        Tesla.Middleware.BaseUrl,
        "https://ddragon.leagueoflegends.com/api"
      },
      Tesla.Middleware.JSON,
      Tesla.Middleware.Logger
    ]

    Tesla.client(middlewares)
  end

  def client(patch, lang \\ @default_lang) do
    middlewares = [
      {
        Tesla.Middleware.BaseUrl,
        "https://ddragon.leagueoflegends.com/cdn/#{patch}/data/#{lang}"
      },
      Tesla.Middleware.JSON,
      Tesla.Middleware.Logger
    ]

    Tesla.client(middlewares)
  end
end
