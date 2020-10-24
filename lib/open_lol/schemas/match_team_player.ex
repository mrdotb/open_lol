defmodule OpenLOL.Schemas.MatchTeamPlayer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias OpenLOL.Canon

  alias OpenLOL.Schemas.{
    Account,
    Champion,
    Item,
    MatchTeam,
    MatchTeamPlayerItem,
    MatchTeamPlayerPerk,
    MatchTeamPlayerSummoner,
    Perk,
    Summoner
  }

  @fields ~w(
    participant_id kills deaths assists
    champ_level gold_earned
    role lane
    champion_id match_team_id account_id
  )a
  @required_fields ~w(
    participant_id kills deaths assists
    champ_level gold_earned
    champion_id match_team_id account_id
  )a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "match_team_players" do
    field :participant_id, :integer
    field :kills, :integer
    field :deaths, :integer
    field :assists, :integer
    field :champ_level, :integer
    field :gold_earned, :integer
    field :role, :string
    field :lane, :string

    belongs_to :champion, Champion
    belongs_to :match_team, MatchTeam
    belongs_to :account, Account

    many_to_many :items, Item, join_through: MatchTeamPlayerItem
    many_to_many :perks, Perk, join_through: MatchTeamPlayerPerk
    many_to_many :summoners, Summoner, join_through: MatchTeamPlayerSummoner
  end

  def create_changeset(raw_data, participant_id) do
    participant = Canon.find_participant(raw_data, participant_id)

    champion =
      Canon.get_champion_by(
        fid: Map.get(participant, "championId"),
        version_id: raw_data[:version_id]
      )

    data = %{
      participant_id: participant_id,
      kills: get_in(participant, ["stats", "kills"]),
      deaths: get_in(participant, ["stats", "deaths"]),
      assists: get_in(participant, ["stats", "assists"]),
      champ_level: get_in(participant, ["stats", "champLevel"]),
      gold_earned: get_in(participant, ["stats", "goldEarned"]),
      role: get_in(participant, ["timeline", "role"]),
      lane: get_in(participant, ["timeline", "lane"]),
      champion_id: champion.id,
      match_team_id: raw_data[:match_team_id],
      account_id: raw_data[:account_id]
    }

    changeset(%__MODULE__{}, data)
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(
      :match_team_id,
      name: "match_team_players_match_team_id_fkey"
    )
    |> foreign_key_constraint(
      :champion_id,
      name: "match_team_players_champion_id_fkey"
    )
    |> foreign_key_constraint(
      :account_id,
      name: "match_team_players_account_id_fkey"
    )
  end
end
