defmodule OpenLOL.Schemas.MatchTeamPlayerPerk do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias OpenLOL.Schemas.{MatchTeamPlayer, Perk}

  @fields ~w(match_team_player_id perk_id)a
  @required_fields ~w(match_team_player_id perk_id)a

  @primary_key false
  @foreign_key_type :binary_id

  schema "match_team_players_perks" do
    belongs_to :match_team_player, MatchTeamPlayer
    belongs_to :perk, Perk

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
      :perk_id,
      name: "match_team_players_perks_perk_id_fkey"
    )
    |> foreign_key_constraint(
      :match_team_player_id,
      name: "match_team_players_perks_match_team_player_id_fkey"
    )
  end
end
