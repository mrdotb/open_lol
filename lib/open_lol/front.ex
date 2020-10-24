defmodule OpenLOL.Front do
  @moduledoc """
  The Front context
  """

  import Ecto.Query, only: [from: 2]

  alias OpenLOL.Schemas.{
    Account,
    Champion,
    Match,
    MatchTeam,
    MatchTeamPlayer,
    Player,
    Team
  }

  alias OpenLOL.Repo

  def get_most_played_champion(current_page \\ 1, per_page \\ 20) do
    query =
      from(c in Champion,
        join: p in MatchTeamPlayer,
        on: c.id == p.champion_id,
        order_by: fragment("sum DESC"),
        limit: ^per_page,
        offset: ^((current_page - 1) * per_page),
        group_by: [c.fid, c.name],
        select: %{played_time: sum(1), fid: c.fid}
      )

    Repo.all(query)
  end

  defmacro sum_boolean(column, boolean) do
    quote do
      fragment("SUM(CASE WHEN ? IS ? THEN 1 ELSE 0 END)", unquote(column), unquote(boolean))
    end
  end

  defmacro winrate(win, game_number) do
    quote do
      fragment("CEIL(CAST(? AS DECIMAL ) / ? * 100) AS ratio", unquote(win), unquote(game_number))
    end
  end

  def get_highest_ratio_champion(current_page \\ 1, per_page \\ 10) do
    query =
      from(t in MatchTeam,
        join: p in MatchTeamPlayer,
        on: p.match_team_id == t.id,
        order_by: fragment("ratio DESC"),
        limit: ^per_page,
        offset: ^((current_page - 1) * per_page),
        group_by: p.champion_id,
        having: sum(1) > 100,
        select: %{
          champion_id: p.champion_id,
          sum: sum(1),
          win_sum: sum_boolean(t.win, true),
          loose_sum: sum_boolean(t.win, false),
          ratio: winrate(sum_boolean(t.win, true), sum(1))
        }
      )

    Repo.all(query)
  end
end
