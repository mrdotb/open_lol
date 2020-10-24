defmodule OpenLOL.Fetcher.Probuild do
  @moduledoc """
  A module to interract with probuilds.net using Tesla library and Floki a HTML Parser.

  How to use ?

      import OpenLOL.Fetcher.Probuild

  {:ok, result} = Probuild.teams()

  See the probuilds website to figure out how it work.
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://www.probuilds.net"
  plug Tesla.Middleware.Logger

  plug Tesla.Middleware.Retry,
    delay: 500,
    max_retries: 10,
    max_delay: 4_000,
    should_retry: fn
      {:ok, %{status: status}} when status in [400, 500] -> true
      {:ok, _} -> false
      {:error, _} -> true
    end

  def teams do
    {:ok, response} = get("/teams")

    response.body
    |> Floki.find(".teams .team")
    |> Enum.map(fn teams_by_region ->
      region =
        Floki.find(teams_by_region, "h3")
        |> Floki.text(deep: false)

      teams_by_region
      |> Floki.find("a")
      |> Enum.map(fn team ->
        image =
          team
          |> Floki.find("img")
          |> Floki.attribute("src")
          |> Enum.at(0)

        team_link =
          team
          |> Floki.attribute("href")
          |> Enum.at(0)

        name =
          team
          |> Floki.find(".team")
          |> Floki.text(deep: false)

        %{image: image, team_link: team_link, name: name, region: region}
      end)
    end)
    |> List.flatten()
  end

  def players(team_endpoint) do
    {:ok, response} = get(URI.encode(team_endpoint))

    response.body
    |> Floki.find(".pro-player-search-results > ul > li > a")
    |> Enum.map(fn player_html ->
      probuild_player_id =
        player_html
        |> Floki.attribute("data-id")
        |> Enum.at(0)

      name =
        player_html
        |> Floki.find(".name")
        |> Floki.text(deep: false)

      background_image =
        player_html
        |> Floki.find("div")
        |> Floki.attribute("style")
        |> Enum.at(0)

      [_fullmatch, image] = Regex.run(~r/url\((.*)\)/, background_image)

      %{image: image, probuild_player_id: probuild_player_id, name: name}
    end)
  end

  defp region_mapper(url) do
    [_fullmatch, region] = Regex.run(~r/show\/(.{1,3})\//, String.downcase(url))

    case region do
      "ru" -> "ru"
      "kr" -> "kr"
      "oce" -> "oc1"
      all -> "#{all}1"
    end
  end

  def accounts(probuild_player_id) do
    {:ok, response} =
      get(
        "/ajax/games?proId=#{probuild_player_id}&limit=100&view=pro_game_history_brief&sort=gameDate-desc&olderThan=0"
      )

    response.body
    |> Jason.decode!()
    |> Enum.map(fn a ->
      a
      |> Floki.parse()
      |> Floki.attribute("href")
      |> Enum.at(0)
      |> String.split("/")
    end)
    |> Enum.uniq_by(fn [_, _, _, _, _, account_id] -> account_id end)
    |> Enum.map(&Enum.join(&1, "/"))
    |> Enum.map(&get(&1))
    |> Enum.map(fn request ->
      {:ok, response} = request

      region = region_mapper(response.url)

      account_name =
        response.body
        |> Floki.find(".summoner.highlighted a")
        |> Floki.text(deep: false)
        |> String.replace(" ", "")

      %{name: account_name, region: region}
    end)
  end
end
