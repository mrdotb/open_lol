defmodule OpenLOL.Repo.Migrations.AddMatchTeamPlayersSummoners do
  use Ecto.Migration

  def up() do
    create table(:match_team_players_summoners, primary_key: false) do
      add :match_team_player_id, references(:match_team_players, type: :binary_id)
      add :summoner_id, references(:summoners, type: :binary_id)

      timestamps()
    end
  end

  def down() do
    drop table("match_team_players_summoners")
  end
end
