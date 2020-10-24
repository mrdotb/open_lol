defmodule OpenLOLWeb.PageController do
  use OpenLOLWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
