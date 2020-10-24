defmodule OpenLOL.Schemas.Helper do
  @moduledoc false

  import Ecto.Changeset

  def slugify(changeset, field) do
    case get_field(changeset, field) do
      nil ->
        changeset

      str ->
        put_change(
          changeset,
          :slug,
          Slug.slugify(str, separator: "-")
        )
    end
  end

  def validate_platform(changeset) do
    validate_inclusion(changeset, :platform, [
      "RU",
      "KR",
      "BR1",
      "OC1",
      "JP1",
      "NA1",
      "EUN1",
      "EUW1",
      "TR1",
      "LA1",
      "LA2"
    ])
  end
end
