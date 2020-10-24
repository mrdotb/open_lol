defmodule OpenLOL.Schemas.Team do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias OpenLOL.Schemas.{
    Helper,
    Player
  }

  @fields ~w(image name region)a
  @required_fields ~w(image name region)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "teams" do
    field :image, :string
    field :name, :string
    field :region, :string
    field :slug, :string

    has_many :players, Player

    timestamps()
  end

  @doc false
  def create_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> Helper.slugify(:name)
    |> unique_constraint(:name, name: :lol_matches_id_region_index)
  end
end
