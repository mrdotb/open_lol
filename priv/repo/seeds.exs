# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     OpenLOL.Repo.insert!(%OpenLOL.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
defmodule OpenLOL.Seeds do
  def call do
    :ok = OpenLOL.Canon.Dragon.start()
  end
end

OpenLOL.Seeds.call()
