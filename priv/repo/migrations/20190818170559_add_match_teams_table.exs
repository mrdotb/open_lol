defmodule OpenLOL.Repo.Migrations.AddMatchTeams do
  use Ecto.Migration

  def up do
    execute("CREATE TYPE team_color AS ENUM ('blue', 'red')")

    create table("match_teams", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :bans, {:array, :smallint}, null: false
      add :win, :boolean, null: false
      add :color, :team_color, null: false

      add :game_id,
          references(:matches, on_delete: :nothing, type: :bigint, column: :game_id),
          null: false
    end

    create index(:match_teams, [:id])
    create unique_index(:match_teams, [:game_id, :color])
  end

  def down do
    drop table("match_teams")

    execute("DROP TYPE team_color")
  end
end
