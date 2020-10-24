defmodule OpenLOL.Repo.Migrations.AddMatchTeamPlayersItems do
  use Ecto.Migration

  def up() do
    create table(:match_team_players_items, primary_key: false) do
      add :match_team_player_id,
          references(:match_team_players, type: :binary_id),
          null: false

      add :item_id,
          references(:items, type: :binary_id),
          null: false

      timestamps()
    end
  end

  def down() do
    drop table("match_team_players_items")
  end
end
