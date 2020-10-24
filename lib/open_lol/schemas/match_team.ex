defmodule OpenLOL.Schemas.MatchTeam do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias OpenLOL.Schemas.{
    Match,
    MatchTeamPlayer
  }

  @fields ~w(bans win color game_id)a
  @required_fields ~w(bans win color game_id)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :integer

  schema "match_teams" do
    field :bans, {:array, :integer}
    field :win, :boolean
    field :color, :string

    belongs_to :match, Match, foreign_key: :game_id, references: :game_id
    has_many :match_team_players, MatchTeamPlayer
  end

  defp prepare_data(:bans, match_team_data) do
    match_team_data
    |> Map.get("bans")
    |> Enum.map(&Map.get(&1, "championId"))
  end

  defp prepare_data(:win, match_team_data) do
    case Map.get(match_team_data, "win") do
      "Win" -> true
      "Fail" -> false
    end
  end

  defp prepare_data(:color, match_team_data) do
    case Map.get(match_team_data, "teamId") do
      100 -> "blue"
      200 -> "red"
    end
  end

  defp prepare_data(match_team_data) do
    %{
      bans: prepare_data(:bans, match_team_data),
      win: prepare_data(:win, match_team_data),
      color: prepare_data(:color, match_team_data),
      game_id: match_team_data[:game_id]
    }
  end

  @doc false
  def create_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(prepare_data(attrs), @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name, name: :match_teams_game_id_color_index)
    |> foreign_key_constraint(:game_id, name: "match_game_id_fkey")
  end
end
