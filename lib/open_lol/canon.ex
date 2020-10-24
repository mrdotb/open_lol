defmodule OpenLOL.Canon do
  @moduledoc """
  The Canon context.
  """

  import Ecto.Query

  alias Ecto.Multi
  alias OpenLOL.Repo

  alias OpenLOL.Schemas.{
    Account,
    Champion,
    Item,
    Match,
    MatchTeam,
    MatchTeamPlayer,
    MatchTeamPlayerItem,
    MatchTeamPlayerPerk,
    MatchTeamPlayerSummoner,
    Perk,
    Player,
    Summoner,
    Team,
    Version
  }

  @doc """
  Get versions.
  """
  def get_versions do
    query = from(v in Version)

    Repo.all(query)
  end

  def get_version_by(query) do
    Repo.get_by(Version, query)
  end

  def get_champion_by(query) do
    Repo.get_by(Champion, query)
  end

  @doc """
  Create champion.
  """
  def create_champion(raw_data) do
    raw_data
    |> Champion.create_changeset()
    |> Repo.insert()
  end

  @doc """
  Create item.
  """
  def create_item(raw_data) do
    raw_data
    |> Item.create_changeset()
    |> Repo.insert()
  end

  def get_item_by(query) do
    Repo.get_by(Item, query)
  end

  def get_items do
    query =
      from i in Item,
        order_by: i.id

    Repo.all(query)
  end

  @doc """
  Create version.
  """
  def create_version(raw_data) do
    raw_data
    |> Version.create_changeset()
    |> Repo.insert()
  end

  @doc """
  Find closest dragon version
  """
  def find_closest_dragon_version(game_version) when is_binary(game_version) do
    game_version
    |> String.split(".")
    |> Enum.map(&Integer.parse/1)
    |> find_closest_dragon_version()
  end

  def find_closest_dragon_version([{major, _}, {minor, _}, {patch, _}, {_, _}]) do
    sql = """
    SELECT id, v[1] as major, v[2] as minor, v[3] as patch,
      CASE
        WHEN v[3]=#{patch}::int THEN '1'
        WHEN POSITION('#{patch}' IN v[3]::text)=1 THEN '2'
        WHEN SUBSTRING('#{patch}', 0, 2)=v[3]::text THEN '3'
      ELSE '0'
      END AS match
      FROM(
        SELECT id, STRING_TO_ARRAY(number, '.')::int[] as v
        FROM versions
      ) t
      WHERE v[1]=$1 AND v[2]=$2
      ORDER BY match DESC
    """

    Repo.query(sql, [major, minor])
    |> find_closest_dragon_version()
  end

  def find_closest_dragon_version({:ok, %Postgrex.Result{num_rows: 0}}) do
    {:error, "game_version not found"}
  end

  def find_closest_dragon_version({:error, exception}) do
    {:error, exception}
  end

  def find_closest_dragon_version({:ok, %Postgrex.Result{rows: rows}}) do
    result =
      rows
      |> Enum.map(fn [id, major, minor, patch, match] ->
        %{
          id: Ecto.UUID.cast!(id),
          major: major,
          minor: minor,
          patch: patch,
          match: match
        }
      end)
      |> Enum.at(0)

    {:ok, result}
  end

  def find_closest_dragon_version(other) when is_list(other) do
    {:error, "game_version format error"}
  end

  @doc """
  Create perk.
  """
  def create_perk(raw_data) do
    raw_data
    |> Perk.create_changeset()
    |> Repo.insert()
  end

  def get_perk_by(query) do
    Repo.get_by(Perk, query)
  end

  @doc """
  Create summoner (spell).
  """
  def create_summoner(raw_data) do
    raw_data
    |> Summoner.create_changeset()
    |> Repo.insert()
  end

  def get_summoner_by(query) do
    Repo.get_by(Summoner, query)
  end

  @doc """
  Create or get a team.
  """
  @spec create_or_get_team(map()) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def create_or_get_team(team_data) do
    changeset = Team.create_changeset(%Team{}, team_data)

    if changeset.valid? do
      team = Repo.get_by(Team, name: team_data[:name]) || Repo.insert!(changeset)
      {:ok, team}
    else
      {:error, changeset}
    end
  end

  @doc """
  Create or get a player.
  """
  @spec create_or_get_player(map()) :: {:ok, Player.t()} | {:error, Ecto.Changeset.t()}
  def create_or_get_player(player_data) do
    changeset = Player.create_changeset(%Player{}, player_data)

    case changeset.valid? do
      true ->
        case Repo.get_by(Player, name: player_data[:name]) do
          nil -> Repo.insert(changeset)
          player -> {:ok, player}
        end

      false ->
        {:error, changeset}
    end
  end

  @doc """
  Create or get a account.
  """
  @spec create_or_get_account(map()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def create_or_get_account(account_data) do
    changeset = Account.create_changeset(%Account{}, account_data)

    case changeset.valid? do
      true ->
        case Repo.get_by(
               Account,
               account_id: account_data[:account_id],
               platform: account_data[:platform]
             ) do
          nil -> Repo.insert(changeset)
          account -> {:ok, account}
        end

      false ->
        {:error, changeset}
    end
  end

  @doc """
  Find Account by.
  """
  @spec find_account_by(keyword()) :: Account.t() | nil
  def find_account_by(query) do
    Repo.get_by(Account, query)
  end

  @doc """
  Get all distinct platforms.
  """
  def get_distinct_platforms do
    query =
      from a in Account,
        distinct: a.platform,
        select: a.platform

    Repo.all(query)
  end

  @doc """
  Find Accounts where.
  """
  @spec find_pro_account_ids_per_platform(String.t()) :: [String.t()] | []
  def find_pro_account_ids_per_platform(platform) do
    query =
      from a in Account,
        where: a.platform == ^platform and not is_nil(a.player_id),
        select: a.account_id

    Repo.all(query)
  end

  @doc """
  Does this match exist ?
  """
  def match_exists?(game_id, platform) do
    query =
      from m in Match,
        where: m.game_id == ^game_id and m.platform == ^platform,
        select: 1

    case Repo.one(query) do
      nil -> false
      _match -> true
    end
  end

  @doc """
  Create match
  """
  def create_match(match_data) do
    Match.create_changeset(match_data)
    |> Repo.insert()
  end

  @doc """
  Create match_team
  """
  def create_match_team(match_team_data) do
    MatchTeam.create_changeset(%MatchTeam{}, match_team_data)
    |> Repo.insert()
  end

  @doc """
  Create match_team_player
  """
  def create_match_team_player(match_team_player_data, participant_id) do
    MatchTeamPlayer.create_changeset(
      %MatchTeamPlayer{},
      match_team_player_data,
      participant_id
    )
  end

  def find_participant_identity(raw_data, participant_id) do
    raw_data
    |> Map.get("participantIdentities")
    |> Enum.find(&(Map.get(&1, "participantId") == participant_id))
  end

  def find_participant(raw_data, participant) when is_map(participant) do
    raw_data
    |> Map.get("participants")
    |> Enum.find(&(Map.get(&1, "participantId") == participant.participant_id))
  end

  def find_participant(raw_data, participant_id) when is_integer(participant_id) do
    raw_data
    |> Map.get("participants")
    |> Enum.find(&(Map.get(&1, "participantId") == participant_id))
  end

  defp create_match_players_items(raw_data, participant) do
    find_participant(raw_data, participant)
    |> Map.get("stats")
    |> Enum.filter(fn {k, _v} ->
      String.contains?(k, "item")
    end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.reject(fn v -> v == 0 end)
    |> Enum.sort()
    |> Enum.map(fn item_id ->
      item =
        get_item_by(
          fid: item_id,
          version_id: raw_data[:version_id]
        )

      %{item_id: item.id, match_team_player_id: participant.id}
    end)
    |> Enum.with_index()
    |> Enum.reduce(
      Multi.new(),
      fn {match_team_player_item_data, index}, multi ->
        Multi.insert(
          multi,
          String.to_atom("item_#{participant.participant_id}_#{index}"),
          MatchTeamPlayerItem.create_changeset(match_team_player_item_data)
        )
      end
    )
  end

  defp create_match_players_perks(raw_data, participant) do
    find_participant(raw_data, participant)
    |> Map.get("stats")
    |> Enum.filter(fn {k, _v} ->
      String.match?(k, ~r/perk([0-5]$|[PS])/)
    end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.sort()
    |> Enum.map(fn perk_id ->
      perk =
        get_perk_by(
          fid: perk_id,
          version_id: raw_data[:version_id]
        )

      %{perk_id: perk.id, match_team_player_id: participant.id}
    end)
    |> Enum.with_index()
    |> Enum.reduce(
      Multi.new(),
      fn {match_team_player_perk_data, index}, multi ->
        Multi.insert(
          multi,
          String.to_atom("perk_#{participant.participant_id}_#{index}"),
          MatchTeamPlayerPerk.create_changeset(match_team_player_perk_data)
        )
      end
    )
  end

  defp create_match_players_summoners(raw_data, participant) do
    find_participant(raw_data, participant)
    |> Map.take(["spell1Id", "spell2Id"])
    |> Map.values()
    |> Enum.map(fn summoner_id ->
      summoner =
        get_summoner_by(
          fid: summoner_id,
          version_id: raw_data[:version_id]
        )

      %{summoner_id: summoner.id, match_team_player_id: participant.id}
    end)
    |> Enum.with_index()
    |> Enum.reduce(
      Multi.new(),
      fn {match_team_player_summoner_data, index}, multi ->
        Multi.insert(
          multi,
          String.to_atom("summoner_#{participant.participant_id}_#{index}"),
          MatchTeamPlayerSummoner.create_changeset(match_team_player_summoner_data)
        )
      end
    )
  end

  def create_match_tree(multi, :match_teams, raw_data) do
    Multi.merge(multi, fn %{match: match} ->
      Enum.reduce(raw_data["teams"], Multi.new(), fn team_data, multi ->
        team_data = Map.put(team_data, :game_id, match.game_id)

        Multi.insert(
          multi,
          team_data["teamId"],
          MatchTeam.create_changeset(%MatchTeam{}, team_data)
        )
      end)
    end)
  end

  def create_match_tree(multi, :accounts, raw_data) do
    Multi.merge(multi, fn _ ->
      Enum.reduce(raw_data["participantIdentities"], Multi.new(), fn participant_identity,
                                                                     multi ->
        account_data = %{
          account_id: get_in(participant_identity, ["player", "accountId"]),
          name: get_in(participant_identity, ["player", "summonerName"]),
          platform: raw_data[:platform]
        }

        case find_account_by(
               platform: account_data[:platform],
               account_id: account_data[:account_id]
             ) do
          nil ->
            Multi.insert(
              multi,
              "account_#{participant_identity["participantId"]}",
              Account.create_changeset(%Account{}, account_data)
            )

          _account ->
            multi
        end
      end)
    end)
  end

  defp find_account_id_in_multi_or_db(raw_data, multi_data, participant_id) do
    case Map.get(multi_data, "account_#{participant_id}") do
      nil ->
        account_id =
          find_participant_identity(raw_data, participant_id)
          |> get_in(["player", "accountId"])

        account =
          find_account_by(
            account_id: account_id,
            platform: raw_data[:platform]
          )

        account.id

      account ->
        account.id
    end
  end

  def create_match_tree(multi, :match_team_players, raw_data) do
    Multi.merge(multi, fn %{100 => blue, 200 => red} = multi_data ->
      Enum.reduce(1..10, Multi.new(), fn participant_id, multi ->
        match_team_id = if(participant_id <= 6, do: blue.id, else: red.id)

        account_id = find_account_id_in_multi_or_db(raw_data, multi_data, participant_id)
        version_id = Map.get(multi_data, :match).version_id

        data =
          raw_data
          |> Map.put(:match_team_id, match_team_id)
          |> Map.put(:account_id, account_id)
          |> Map.put(:version_id, version_id)

        Multi.insert(
          multi,
          participant_id,
          MatchTeamPlayer.create_changeset(data, participant_id)
        )
      end)
    end)
  end

  def create_match_tree(multi, :many_to_many, raw_data, function) do
    Multi.merge(multi, fn multi_data ->
      Enum.reduce(1..10, Multi.new(), fn participant_id, multi ->
        version_id = Map.get(multi_data, :match).version_id
        data = Map.put(raw_data, :version_id, version_id)
        participant = Map.get(multi_data, participant_id)

        Multi.append(
          multi,
          function.(data, participant)
        )
      end)
    end)
  end

  def create_match_tree(raw_data) do
    Multi.new()
    |> Multi.insert(:match, Match.create_changeset(raw_data))
    |> create_match_tree(:match_teams, raw_data)
    |> create_match_tree(:accounts, raw_data)
    |> create_match_tree(:match_team_players, raw_data)
    |> create_match_tree(:many_to_many, raw_data, &create_match_players_items/2)
    |> create_match_tree(:many_to_many, raw_data, &create_match_players_perks/2)
    |> create_match_tree(:many_to_many, raw_data, &create_match_players_summoners/2)
    |> Repo.transaction()
  end
end
