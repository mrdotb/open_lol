defmodule OpenLOL.Canon.Probuild do
  @moduledoc false

  use GenServer

  import Logger

  alias OpenLOL.Canon
  alias OpenLOL.Fetcher

  @timer 5 * 3600 * 1000

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    start()
    schedule_work()
    {:noreply, state}
  end

  def schedule_work do
    Process.send_after(self(), :work, @timer)
  end

  def start do
    process_teams()
    |> process_players()
    |> process_accounts()
  end

  defp process_teams do
    Fetcher.Probuild.teams()
    |> Stream.map(&process_team(&1))
    |> Stream.filter(&(&1 !== :error))
  end

  defp process_team(team_data) do
    case Canon.create_or_get_team(team_data) do
      {:ok, team} ->
        %{id: team.id, link: team_data[:team_link]}

      {:error, changeset} ->
        Logger.error(
          "#{__MODULE__}.process_team() #{inspect(changeset.errors)}\n#{inspect(team_data)}"
        )

        :error
    end
  end

  defp process_players(teams) do
    teams
    |> Enum.map(fn team ->
      Fetcher.Probuild.players(team.link)
      |> Enum.map(&process_player(team.id, &1))
    end)
    |> List.flatten()
    |> Enum.filter(&(&1 !== :error))
  end

  defp process_player(team_id, player_data) do
    player_data = Map.merge(%{team_id: team_id}, player_data)

    case Canon.create_or_get_player(player_data) do
      {:ok, player} ->
        %{id: player.id, probuild_player_id: player_data[:probuild_player_id]}

      {:error, changeset} ->
        Logger.error(
          "#{__MODULE__}.process_player() #{inspect(changeset.errors)}\n#{inspect(player_data)}"
        )

        :error
    end
  end

  defp process_accounts(players) do
    players
    |> Enum.map(fn player ->
      Fetcher.Probuild.accounts(player[:probuild_player_id])
      |> Enum.map(&Map.merge(&1, %{player_id: player[:id]}))
    end)
    |> List.flatten()
    |> Enum.each(&process_account(&1))
  end

  defp process_account(%{player_id: player_id, name: name, region: platform} = account_data) do
    case Canon.find_account_by(name: name, platform: String.upcase(platform)) do
      nil ->
        client = Fetcher.RiotAPI.client(platform)

        case Fetcher.RiotAPI.summoner_by_name(client, name) do
          {:ok, %{status: 200, body: body}} ->
            %{
              player_id: player_id,
              account_id: body["accountId"],
              name: name,
              platform: String.upcase(platform)
            }
            |> Canon.create_or_get_account()

          {:ok, %{status: status} = result} ->
            Logger.error(
              "#{__MODULE__}.process_account() #{inspect(result)}\n#{inspect(account_data)}"
            )

          {:error, result} ->
            Logger.error(
              "#{__MODULE__}.process_account() #{inspect(result)}\n#{inspect(account_data)}"
            )

          other ->
            Logger.info(other)
        end

      account ->
        account
    end
  end
end
