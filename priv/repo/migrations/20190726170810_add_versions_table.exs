defmodule OpenLOL.Repo.Migrations.AddVersionsTable do
  use Ecto.Migration

  def up() do
    create table(:versions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :number, :text, null: false

      timestamps()
    end

    create index(:versions, [:id])
    create unique_index(:versions, [:number])
  end

  def down() do
    drop table("versions")
  end
end
