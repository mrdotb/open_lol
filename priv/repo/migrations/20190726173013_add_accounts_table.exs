defmodule OpenLOL.Repo.Migrations.AddAccountsTable do
  use Ecto.Migration

  def up do
    execute(
      "CREATE TYPE platform AS ENUM ('RU', 'KR', 'BR1', 'OC1', 'JP1', 'NA1', 'EUN1', 'EUW1', 'TR1', 'LA1', 'LA2')"
    )

    create table("accounts", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, :text, null: false
      add :name, :text, null: false
      add :platform, :platform, null: false
      # add :puuid, :text, primary_key: false
      # add :id, :text, null: false

      add :player_id,
          references(:players, on_delete: :nothing, type: :binary_id),
          null: true

      timestamps()
    end

    create index(:accounts, [:id])
    create unique_index(:accounts, [:account_id, :platform])
  end

  def down do
    drop table("accounts")

    execute("DROP TYPE platform")
  end
end
