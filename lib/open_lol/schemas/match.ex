defmodule OpenLOL.Schemas.Match do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias OpenLOL.Canon

  alias OpenLOL.Schemas.{
    Helper,
    MatchTeam,
    Version
  }

  @fields ~w(game_id game_creation_unix game_duration game_version version_id platform)a
  @required_fields ~w(game_id game_creation_unix game_duration game_version platform)a

  @primary_key {:game_id, :integer, autogenerate: false}
  @foreign_key_type :binary_id

  schema "matches" do
    field :game_creation_unix, :integer, virtual: true
    field :game_creation, :utc_datetime
    field :game_duration, :integer
    field :platform, :string
    field :game_version, :string

    belongs_to :version, Version

    has_many :match_teams, MatchTeam

    timestamps()
  end

  defp convert_unix_timestamp(changeset) do
    case get_field(changeset, :game_creation_unix) do
      nil ->
        changeset

      timestamp ->
        game_creation =
          timestamp
          |> DateTime.from_unix!(:millisecond)
          |> DateTime.truncate(:second)

        put_change(changeset, :game_creation, game_creation)
    end
  end

  defp set_version_id(changeset) do
    case get_field(changeset, :game_version) do
      nil ->
        changeset

      game_version ->
        case Canon.find_closest_dragon_version(game_version) do
          {:ok, %{id: id}} ->
            put_change(changeset, :version_id, id)

          {:error, error} ->
            add_error(changeset, :name, "could not find version #{inspect(error)}")
        end
    end
  end

  def create_changeset(%{
        "gameId" => game_id,
        "gameCreation" => game_creation_unix,
        "gameDuration" => game_duration,
        "gameVersion" => game_version,
        :platform => platform
      }) do
    data = %{
      game_id: game_id,
      game_creation_unix: game_creation_unix,
      game_duration: game_duration,
      game_version: game_version,
      platform: platform
    }

    changeset(%__MODULE__{}, data)
  end

  @doc false
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> convert_unix_timestamp()
    |> set_version_id()
    |> Helper.validate_platform()
    |> unique_constraint(:name, name: :matches_game_id_platform_index)
    |> foreign_key_constraint(:game_id, name: "match_teams_game_id_fkey")
  end
end
