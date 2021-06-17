defmodule AssetsWeb.PageController do
  use AssetsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
