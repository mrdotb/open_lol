defmodule OpenLOL.Schemas.Version do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(number)a
  @required_fields ~w(number)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "versions" do
    field :number, :string

    timestamps()
  end

  def create_changeset(number) when is_binary(number) do
    changeset(%__MODULE__{}, %{number: number})
  end

  @doc false
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:number)
  end
end
