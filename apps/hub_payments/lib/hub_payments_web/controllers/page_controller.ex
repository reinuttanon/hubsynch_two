defmodule HubPaymentsWeb.PageController do
  use HubPaymentsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", layout: false)
  end
end
