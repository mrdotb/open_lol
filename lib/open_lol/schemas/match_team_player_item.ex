defmodule OpenLOL.Schemas.MatchTeamPlayerItem do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias OpenLOL.Schemas.{
    Item,
    MatchTeamPlayer
  }

  @fields ~w(match_team_player_id item_id)a
  @required_fields ~w(match_team_player_id item_id)a

  @primary_key false
  @foreign_key_type :binary_id

  schema "match_team_players_items" do
    belongs_to :match_team_player, MatchTeamPlayer
    belongs_to :item, Item

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
      :item_id,
      name: "match_team_players_items_item_id_fkey"
    )
    |> foreign_key_constraint(
      :match_team_player_id,
      name: "match_team_players_items_match_team_player_id_fkey"
    )
  end
end
