defmodule OpenLOL.Repo.Migrations.AddMatchTeamPlayersTable do
  use Ecto.Migration

  def up do
    execute(
      "CREATE TYPE lane AS ENUM ('MID', 'NONE', 'MIDDLE', 'TOP', 'JUNGLE', 'BOT', 'BOTTOM')"
    )

    execute("CREATE TYPE role AS ENUM ('DUO', 'NONE', 'SOLO', 'DUO_CARRY', 'DUO_SUPPORT')")

    create table("match_team_players", primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :participant_id, :smallint, null: false
      add :kills, :smallint, null: false
      add :deaths, :smallint, null: false
      add :assists, :smallint, null: false
      add :champ_level, :smallint, null: false
      add :gold_earned, :integer, null: false
      add :lane, :lane, null: true
      add :role, :role, null: true

      add :champion_id,
          references(:champions, on_delete: :nothing, type: :binary_id),
          null: false

      add :match_team_id,
          references(:match_teams, on_delete: :nothing, type: :binary_id),
          null: false

      add :account_id,
          references(:accounts, on_delete: :nothing, type: :binary_id),
          null: false
    end

    create index(:match_team_players, [:id])
  end

  def down do
    drop table("match_team_players")

    execute("DROP TYPE lane, role")
  end
end
