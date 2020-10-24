defmodule OpenLOL.Repo.Migrations.AddPlayersTable do
  use Ecto.Migration

  def up do
    create table("players", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :image, :text, null: false
      add :name, :citext, null: false
      add :slug, :text, null: false

      add :team_id,
          references(:teams, on_delete: :nothing, type: :binary_id),
          null: false

      timestamps()
    end

    create index(:players, [:id])
    create unique_index(:players, [:name])
  end

  def down do
    drop table("players")
  end
end
