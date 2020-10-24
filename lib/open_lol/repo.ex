defmodule OpenLOL.Repo do
  use Ecto.Repo,
    otp_app: :open_lol,
    adapter: Ecto.Adapters.Postgres
end
