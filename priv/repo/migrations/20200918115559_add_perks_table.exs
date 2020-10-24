defmodule OpenLOL.Repo.Migrations.AddPerksTable do
  use Ecto.Migration

  def up() do
    create table("perks", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fid, :integer, null: false
      add :icon, :text, null: false
      add :name, :text, null: false
      add :short_desc, :text, null: true

      add :version_id,
          references(:versions, on_delete: :nothing, type: :binary_id),
          null: false

      timestamps()
    end

    create index(:perks, [:id])
    create unique_index(:perks, [:fid, :version_id])
  end

  def down() do
    drop table("perks")
  end
end
