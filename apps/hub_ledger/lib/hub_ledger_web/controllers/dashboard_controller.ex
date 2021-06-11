defmodule HubLedgerWeb.DashboardController do
  @moduledoc false

  use HubLedgerWeb, :controller

  def index(conn, _) do
    render(conn, "index.html")
  end
end
