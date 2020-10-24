defmodule OpenLOL.Repo.Migrations.AddMatchTeamPlayersPerks do
  use Ecto.Migration

  def up() do
    create table(:match_team_players_perks, primary_key: false) do
      add :match_team_player_id,
          references(:match_team_players, type: :binary_id)

      add :perk_id, references(:perks, type: :binary_id)

      timestamps()
    end
  end

  def down() do
    drop table("match_team_players_perks")
  end
end
