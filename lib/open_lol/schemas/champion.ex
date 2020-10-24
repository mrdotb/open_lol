defmodule OpenLOL.Schemas.Champion do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias OpenLOL.Schemas.Version

  @fields ~w(version_id fid name image)a
  @required_fields ~w(version_id fid name image)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "champions" do
    field :fid, :integer
    field :name, :string
    field :image, :string

    belongs_to :version, Version

    timestamps()
  end

  @doc false
  def create_changeset(%{
        "key" => fid,
        "image" => %{"full" => image},
        "name" => name,
        :version_id => version_id
      }) do
    data = %{fid: fid, name: name, image: image, version_id: version_id}
    changeset(%__MODULE__{}, data)
  end

  @doc false
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name, name: :champions_fid_version_id_index)
  end
end
