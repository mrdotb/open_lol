defmodule OpenLOL.Schemas.Account do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias OpenLOL.Schemas.{
    Helper,
    MatchTeamPlayer,
    Player
  }

  @fields ~w(account_id name platform player_id)a
  @required_fields ~w(account_id name platform)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "accounts" do
    field :account_id, :string
    field :name, :string
    field :platform, :string

    belongs_to :player, Player
    has_many :match_team_player, MatchTeamPlayer

    timestamps()
  end

  @doc false
  def create_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:account_id)
    |> Helper.validate_platform()
    |> foreign_key_constraint(:player_id, name: "accounts_player_id_fkey")
  end
end
