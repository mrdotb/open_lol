defmodule OpenLOL.Repo.Migrations.AddSummonersTable do
  use Ecto.Migration

  def up() do
    create table("summoners", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fid, :integer, null: false
      add :name, :text, null: false
      add :image, :text, null: false
      add :description, :text, null: false

      add :version_id,
          references(:versions, on_delete: :nothing, type: :binary_id),
          null: false

      timestamps()
    end

    create unique_index(:summoners, [:fid, :version_id])
  end

  def down() do
    drop table("summoners")
  end
end
