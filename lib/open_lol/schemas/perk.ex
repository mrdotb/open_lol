defmodule OpenLOL.Schemas.Perk do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias OpenLOL.Schemas.Version

  @fields ~w(version_id fid icon name short_desc)a
  @required_fields ~w(version_id fid icon name)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "perks" do
    field :fid, :integer
    field :icon, :string
    field :name, :string
    field :short_desc, :string

    belongs_to :version, Version

    timestamps()
  end

  @doc false
  def create_changeset(%{
        "icon" => icon,
        "id" => fid,
        "name" => name,
        "shortDesc" => short_desc,
        :version_id => version_id
      }) do
    data = %{
      fid: fid,
      icon: icon,
      name: name,
      short_desc: short_desc,
      version_id: version_id
    }

    changeset(%__MODULE__{}, data)
  end

  def create_changeset(%{
        "icon" => icon,
        "id" => fid,
        "name" => name,
        :version_id => version_id
      }) do
    changeset(
      %__MODULE__{},
      %{fid: fid, icon: icon, name: name, version_id: version_id}
    )
  end

  @doc false
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name, name: :perks_fid_version_id_index)
  end
end
