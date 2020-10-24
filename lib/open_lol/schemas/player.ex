defmodule OpenLOL.Schemas.Player do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias OpenLOL.Schemas.{
    Account,
    Helper,
    Team
  }

  @fields ~w(image name team_id)a
  @required_fields ~w(image name team_id)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "players" do
    field :image, :string
    field :name, :string
    field :slug, :string

    belongs_to :team, Team
    has_many :accounts, Account

    timestamps()
  end

  @doc false
  def create_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> Helper.slugify(:name)
    |> foreign_key_constraint(:team_id, name: "players_team_id_fkey")
    |> unique_constraint(:name)
  end
end
