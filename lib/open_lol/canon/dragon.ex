defmodule OpenLOL.Canon.Dragon do
  @moduledoc false

  alias OpenLOL.Canon
  alias OpenLOL.Fetcher

  @from 9

  def start do
    process_versions()

    versions = Canon.get_versions()

    process_champions(versions)
    process_items(versions)
    process_perks(versions)
    process_summoners(versions)
  end

  def process_versions do
    client = Fetcher.Dragon.client()
    {:ok, %{body: body, status: 200}} = Fetcher.Dragon.versions(client)

    body
    |> Enum.reject(fn version ->
      version
      |> String.split(".")
      |> Enum.at(0)
      |> Integer.parse()
      |> case do
        {version, _} ->
          version < @from

        _ ->
          true
      end
    end)
    |> Enum.each(&Canon.create_version/1)
  end

  def process_champions(versions) do
    versions
    |> Enum.each(fn version ->
      client = Fetcher.Dragon.client(version.number)

      {:ok, %{body: body, status: 200}} = Fetcher.Dragon.champions(client)

      body["data"]
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.map(&Map.put(&1, :version_id, version.id))
      |> Enum.each(&Canon.create_champion/1)
    end)
  end

  def process_items(versions) do
    versions
    |> Enum.each(fn version ->
      client = Fetcher.Dragon.client(version.number)

      {:ok, %{body: body, status: 200}} = Fetcher.Dragon.items(client)

      body["data"]
      |> Enum.map(fn {k, v} -> Map.put(v, "id", k) end)
      |> Enum.map(&Map.put(&1, :version_id, version.id))
      |> Enum.each(&Canon.create_item/1)
    end)
  end

  def process_perks(versions) do
    versions
    |> Enum.each(fn version ->
      client = Fetcher.Dragon.client(version.number)

      {:ok, %{body: body, status: 200}} = Fetcher.Dragon.perks(client)

      body
      |> Enum.map(&map_perk/1)
      |> List.flatten()
      |> Enum.map(&Map.put(&1, :version_id, version.id))
      |> Enum.each(&Canon.create_perk/1)
    end)
  end

  defp map_perk(style) do
    Enum.map(style["slots"], fn slot ->
      Enum.map(slot["runes"], &Map.take(&1, ~w(id name icon shortDesc)))
    end)
    |> List.flatten()
    |> List.insert_at(0, Map.take(style, ~w(id name icon shortDesc)))
  end

  def process_summoners(versions) do
    versions
    |> Enum.each(fn version ->
      client = Fetcher.Dragon.client(version.number)

      {:ok, %{body: body, status: 200}} = Fetcher.Dragon.summoners(client)

      body["data"]
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.map(&Map.put(&1, :version_id, version.id))
      |> Enum.each(&Canon.create_summoner/1)
    end)
  end
end
