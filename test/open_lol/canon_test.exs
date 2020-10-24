defmodule OpenLOL.CanonTest do
  use OpenLOL.DataCase, async: true

  alias OpenLOL.Canon

  describe "teams" do
    alias OpenLOL.Schemas.Team

    @valid_attrs %{image: "urlofsktimage.png", name: "skt1", region: "Korea"}
    @invalid_attrs %{image: "", name: "", region: "Korea"}

    def team_fixtures(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Canon.create_or_get_team()

      team
    end

    test "create_or_get_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} = Canon.create_or_get_team(@valid_attrs)
      assert team.image == "urlofsktimage.png"
      assert team.name == "skt1"
      assert team.region == "Korea"
    end

    test "create_or_get_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Canon.create_or_get_team(@invalid_attrs)
    end
  end

  describe "players" do
    alias OpenLOL.Schemas.Player

    @valid_attrs %{image: "urloffakerimage.jpeg", name: "Faker"}
    @invalid_attrs %{image: "", name: ""}

    def player_fixtures(attrs \\ %{}) do
      team = team_fixtures()

      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:team_id, team.id)
        |> Canon.create_or_get_player()

      player
    end

    test "create_or_get_player/1 with valid data creates a player" do
      team = team_fixtures()

      player_data =
        @valid_attrs
        |> Map.put(:team_id, team.id)

      assert {:ok, %Player{} = player} = Canon.create_or_get_player(player_data)
      assert player.image == "urloffakerimage.jpeg"
      assert player.name == "Faker"
    end

    test "create_or_get_player/1 with invalid data returns a error changeset" do
      team = team_fixtures()

      player_data =
        @invalid_attrs
        |> Map.put(:team_id, team.id)

      assert {:error, %Ecto.Changeset{}} = Canon.create_or_get_player(player_data)
    end

    test "create_or_get_player/1 with invalid team returns a error changeset" do
      team_id = Ecto.UUID.generate()

      player_data =
        @valid_attrs
        |> Map.put(:team_id, team_id)

      assert {:error, %Ecto.Changeset{} = changeset} = Canon.create_or_get_player(player_data)
      assert [team_id: {"does not exist", _}] = changeset.errors
    end
  end

  describe "accounts" do
    alias OpenLOL.Schemas.Account

    @valid_attrs %{
      account_id: "F-osoWXWVMMIMzzQeWlW1fKISOWUGCzaE-5F9Aa8cRfURD0",
      name: "우리백정새끼머함",
      platform: "KR"
    }

    @invalid_attrs %{account_id: "", name: "", platform: ""}

    def account_fixtures(attrs \\ @valid_attrs) do
      player = player_fixtures()

      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:player_id, player.id)
        |> Canon.create_or_get_account()

      player
    end

    test "create_or_get_account/1 without player_id creates a account" do
      assert {:ok, %Account{} = account} = Canon.create_or_get_account(@valid_attrs)
    end

    test "create_or_get_account/1 with valid data creates a account" do
      player = player_fixtures()

      account_data =
        @valid_attrs
        |> Map.put(:player_id, player.id)

      assert {:ok, %Account{} = account} = Canon.create_or_get_account(account_data)
    end

    test "create_or_get_account/1 with invalid return a changeset error" do
      player = player_fixtures()

      account_data =
        @invalid_attrs
        |> Map.put(:player_id, player.id)

      assert {:error, %Ecto.Changeset{} = changeset} = Canon.create_or_get_account(account_data)
    end

    test "create_or_get_account/1 with invalid player_id returns a changeset error" do
      account_data =
        @invalid_attrs
        |> Map.put(:player_id, Ecto.UUID.generate())

      assert {:error, %Ecto.Changeset{} = changeset} = Canon.create_or_get_account(account_data)
    end

    test "find_account_by/1 with valid data returns a Account" do
      account = account_fixtures()
      query = Enum.to_list(@valid_attrs)

      assert account == Canon.find_account_by(name: account.name)
      assert account == Canon.find_account_by(query)
    end

    test "find_account_by/1 with invalid data returns null" do
      assert nil == Canon.find_account_by(name: "bob")
    end

    test "get_distinct_platforms/0 returns a list of the distinct platforms" do
      account = account_fixtures()

      assert [account.platform] == Canon.get_distinct_platforms()
    end

    test "find_pro_account_ids_per_platform/1 returns a list of account_id" do
      account = account_fixtures()

      assert [account.account_id] == Canon.find_pro_account_ids_per_platform(account.platform)
    end
  end

  describe "match" do
    @valid_attrs %{
      "gameId" => 4_544_584_520,
      "gameCreation" => 1_596_223_100_304,
      "gameDuration" => 1482,
      "gameVersion" => "10.15.330.344",
      platform: "EUW1"
    }

    def match_fixtures(attrs \\ @valid_attrs) do
      version_fixtures("10.15.1")

      {:ok, match} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Canon.create_match()

      match
    end

    test "create_match/1 should create match with correct attrs" do
      version_fixtures("10.15.1")
      assert {:ok, match} = Canon.create_match(@valid_attrs)
    end

    test "create_match/1 with raw_game_data should create a match" do
      version_fixtures("10.15.1")

      raw =
        CanonFixture.raw_game_data()
        |> Map.put(:platform, "EUW1")

      assert {:ok, match} = Canon.create_match(raw)
    end

    test "match_exists?/2 should return true if match exist" do
      match = match_fixtures()
      assert true = Canon.match_exists?(match.game_id, match.platform)
    end
  end

  describe "match_team" do
    @valid_attrs %{
      "bans" => [
        %{"championId" => 133, "pickTurn" => 6},
        %{"championId" => 154, "pickTurn" => 7},
        %{"championId" => 86, "pickTurn" => 8},
        %{"championId" => 157, "pickTurn" => 9},
        %{"championId" => 30, "pickTurn" => 10}
      ],
      "teamId" => 100,
      "win" => "Fail"
    }

    def match_team_fixtures(attrs \\ @valid_attrs) do
      match = match_fixtures()

      {:ok, match_team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:game_id, match.game_id)
        |> Canon.create_match_team()

      match_team
    end

    test "create_match_team/1 should create a match_team with correct data" do
      match = match_fixtures()

      match_team_data =
        @valid_attrs
        |> Map.put(:game_id, match.game_id)

      assert {:ok, match_team} = Canon.create_match_team(match_team_data)
    end

    test "create_match_team/1 without game_id should return a error changeset" do
      assert {:error, %Ecto.Changeset{}} = Canon.create_match_team(@valid_attrs)
    end

    test "create_match_team/1 without unique (game_id color) should return a error changeset" do
      match = match_fixtures()

      match_team_data =
        @valid_attrs
        |> Map.put(:game_id, match.game_id)

      assert {:ok, _data} = Canon.create_match_team(match_team_data)
      assert {:error, %Ecto.Changeset{}} = Canon.create_match_team(match_team_data)
    end
  end

  describe "full match from raw" do
    test "create_match_tree/1" do
      OpenLOL.Canon.Dragon.process_versions()
      version = Canon.get_version_by(number: "10.15.1")
      versions = [version]
      OpenLOL.Canon.Dragon.process_champions(versions)
      OpenLOL.Canon.Dragon.process_items(versions)
      OpenLOL.Canon.Dragon.process_perks(versions)
      OpenLOL.Canon.Dragon.process_summoners(versions)

      {:ok, _account} =
        Canon.create_or_get_account(%{
          account_id: "F-osoWXWVMMIMzzQeWlW1fKISOWUGCzaE-5F9Aa8cRfURD0",
          name: "우리백정새끼머함",
          platform: "KR"
        })

      raw =
        CanonFixture.raw_game_data()
        |> Map.put(:platform, "KR")

      {:ok, _data} = Canon.create_match_tree(raw)
    end
  end

  describe "version" do
    alias OpenLOL.Schemas.Version

    @valid_attrs "10.19.1"

    def version_fixtures(number \\ @valid_attrs) do
      {:ok, version} =
        number
        |> Canon.create_version()

      version
    end

    test "create_version/1 must create a version" do
      assert {:ok, _version} = Canon.create_version(@valid_attrs)
    end

    test "create_version/1 must create unique version" do
      assert {:ok, _version} = Canon.create_version(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Canon.create_version(@valid_attrs)
    end

    test "find_closest_dragon_version/1 must find the closest version" do
      Canon.Dragon.process_versions()

      assert {:ok, %{major: 10, minor: 15, patch: 1}} =
               Canon.find_closest_dragon_version("10.15.330.344")

      assert {:ok, %{major: 10, minor: 10, patch: 5}} =
               Canon.find_closest_dragon_version("10.10.5.344")
    end

    test "find_closest_dragon_version/1 version not found" do
      assert {:error, "game_version not found"} = Canon.find_closest_dragon_version("19.19.19.19")
    end

    test "find_closest_dragon_version/1 must be given a valid version format" do
      assert {:error, "game_version format error"} =
               Canon.find_closest_dragon_version("10.15.330")

      assert {:error, "game_version format error"} = Canon.find_closest_dragon_version("")

      assert {:error, "game_version format error"} = Canon.find_closest_dragon_version("10.12")

      assert {:error, "game_version format error"} =
               Canon.find_closest_dragon_version("10.15.12.12.12")
    end
  end

  describe "champion" do
    @valid_attrs %{
      "id" => "Ziggs",
      "image" => %{"full" => "Ziggs.png"},
      "key" => "115",
      "name" => "Ziggs"
    }

    def champion_fixtures(attrs \\ %{}) do
      version = version_fixtures()

      {:ok, champion} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:version_id, version.id)
        |> Canon.create_champion()

      champion
    end

    test "create_champion/1 must creates a champion" do
      version = version_fixtures()

      {:ok, _champion} =
        @valid_attrs
        |> Map.put(:version_id, version.id)
        |> Canon.create_champion()
    end

    test "create_champion/1 champion must be unique" do
      version = version_fixtures()

      data =
        @valid_attrs
        |> Map.put(:version_id, version.id)

      assert {:ok, _champion} = Canon.create_champion(data)
      assert {:error, %Ecto.Changeset{}} = Canon.create_champion(data)
    end
  end

  describe "item" do
    @valid_attrs %{
      "id" => "3086",
      "image" => %{
        "full" => "3086.png"
      },
      "name" => "Zeal"
    }

    def item_fixtures(attrs \\ %{}) do
      version = version_fixtures()

      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:version_id, version.id)
        |> Canon.create_item()

      item
    end

    test "create_item/1 must creates a item" do
      version = version_fixtures()

      data =
        @valid_attrs
        |> Map.put(:version_id, version.id)

      {:ok, _item} = Canon.create_item(data)
    end

    test "create_item/1 must be unique" do
      version = version_fixtures()

      data =
        @valid_attrs
        |> Map.put(:version_id, version.id)

      {:ok, _item} = Canon.create_item(data)
      assert {:error, %Ecto.Changeset{}} = Canon.create_item(data)
    end
  end

  describe "perk" do
    @valid_attrs %{
      "icon" => "perk-images/Styles/Resolve/GraspOfTheUndying/GraspOfTheUndying.png",
      "id" => 8437,
      "name" => "Grasp of the Undying",
      "shortDesc" =>
        "Every 4s your next attack on a champion deals bonus magic damage, heals you, and permanently increases your health."
    }

    test "create_perk/1 should creates a perk" do
      version = version_fixtures()

      data =
        @valid_attrs
        |> Map.put(:version_id, version.id)

      {:ok, _perk} = Canon.create_perk(data)
    end

    test "create_perk/1 must be unique" do
      version = version_fixtures()

      data =
        @valid_attrs
        |> Map.put(:version_id, version.id)

      {:ok, _perk} = Canon.create_perk(data)
      {:error, %Ecto.Changeset{}} = Canon.create_perk(data)
    end
  end

  describe "summoner" do
    @valid_attrs %{
      "image" => %{
        "full" => "SummonerTeleport.png"
      },
      "key" => "12",
      "name" => "Teleport",
      "description" =>
        "After channeling for 4 seconds, teleports your champion to target allied structure, minion, or ward and grants a Movement Speed boost. The cooldown of Teleport scales from
 420-240 seconds depending on champion level."
    }

    test "create_summoner/1 should creates a summoner spell" do
      version = version_fixtures()

      data =
        @valid_attrs
        |> Map.put(:version_id, version.id)

      {:ok, _summoner} = Canon.create_summoner(data)
    end

    test "create_summoner/1 must be unique" do
      version = version_fixtures()

      data =
        @valid_attrs
        |> Map.put(:version_id, version.id)

      Canon.create_summoner(data)
      {:error, %Ecto.Changeset{}} = Canon.create_summoner(data)
    end
  end
end
