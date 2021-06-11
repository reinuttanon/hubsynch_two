defmodule HubCrmWeb.PageController do
  use HubCrmWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
