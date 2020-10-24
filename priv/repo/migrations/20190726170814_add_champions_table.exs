defmodule OpenLOL.Repo.Migrations.AddChampionsTable do
  use Ecto.Migration

  def up do
    create table("champions", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fid, :integer, null: false
      add :name, :text, null: false
      add :image, :text, null: false

      add :version_id,
          references(:versions, on_delete: :nothing, type: :binary_id),
          null: false

      timestamps()
    end

    create index(:champions, [:id])
    create unique_index(:champions, [:fid, :version_id])
  end

  def down do
    drop table("champions")
  end
end
