defmodule OpenLOL.Repo.Migrations.AddTeamsTable do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table("teams", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :image, :text, null: true
      add :name, :citext, null: false
      add :region, :citext, null: false
      add :slug, :text, null: false

      timestamps()
    end

    create index(:teams, [:id])
    create unique_index(:teams, [:name, :region])
  end

  def down do
    drop table("teams")

    execute("DROP EXTENSION citext")
  end
end
