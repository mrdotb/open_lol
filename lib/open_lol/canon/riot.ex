defmodule OpenLOL.Canon.Riot do
  @moduledoc false

  use GenServer

  require Logger
  alias OpenLOL.Canon
  alias OpenLOL.Fetcher.RiotAPI

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(platform) do
    schedule_work(platform)
    {:ok, platform}
  end

  def handle_info(:work, platform) do
    start(platform)
    schedule_work(platform)
    {:noreply, platform}
  end

  def schedule_work(platform) do
    Process.send_after(self(), :work, 30_000)
  end

  def start(platform) do
    process_pro_accounts(platform)
  end

  defp process_pro_accounts(platform) do
    client = RiotAPI.client(platform)

    Canon.find_pro_account_ids_per_platform(platform)
    |> Enum.each(fn account_id ->
      {:ok, %{body: body}} = RiotAPI.matchlists_by_account(client, account_id)

      body["matches"]
      |> Enum.each(fn match ->
        game_id = match["gameId"]

        with false <- Canon.match_exists?(game_id, platform),
             {:ok, %{body: body, status: 200}} <- RiotAPI.match_by_id(client, game_id),
             match_data <- Map.put(body, :platform, platform),
             {:ok, match} <- Canon.create_match_tree(match_data) do
          Logger.info("match #{game_id} successfully created")
        else
          true ->
            Logger.info("match #{game_id} already exist")

          other ->
            Logger.info("other #{inspect(other)}")
        end
      end)
    end)
  end
end
