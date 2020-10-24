defmodule OpenLOL.Repo.Migrations.AddMatchesTable do
  use Ecto.Migration

  def up do
    create table("matches", primary_key: false) do
      add :game_id, :bigint, primary_key: true
      add :game_creation, :utc_datetime, null: false
      add :game_duration, :bigint, null: false
      add :game_version, :text, null: false
      add :platform, :platform, null: false

      add :version_id,
          references(:versions, on_delete: :nothing, type: :binary_id),
          null: false

      timestamps()
    end

    create index(:matches, [:game_id])
    create unique_index(:matches, [:game_id, :platform])
  end

  def down do
    drop table("matches")
  end
end
