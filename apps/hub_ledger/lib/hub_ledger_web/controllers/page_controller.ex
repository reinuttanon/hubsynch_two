defmodule HubLedgerWeb.PageController do
  use HubLedgerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", layout: false)
  end
end
