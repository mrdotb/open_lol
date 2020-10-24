defmodule OpenLOL.Schemas.MatchTeamPlayerSummoner do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias OpenLOL.Schemas.{MatchTeamPlayer, Summoner}

  @fields ~w(match_team_player_id summoner_id)a
  @required_fields ~w(match_team_player_id summoner_id)a

  @primary_key false
  @foreign_key_type :binary_id

  schema "match_team_players_summoners" do
    belongs_to :match_team_player, MatchTeamPlayer
    belongs_to :summoner, Summoner

    timestamps()
  end

  def create_changeset(data) do
    changeset(%__MODULE__{}, data)
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(
      :summoner_id,
      name: "match_team_players_summoners_summoner_id_fkey"
    )
    |> foreign_key_constraint(
      :match_team_player_id,
      name: "match_team_players_summoners_match_team_player_id_fkey"
    )
  end
end
