defmodule HubIdentityWeb.DocumentationController do
  @moduledoc false

  use HubIdentityWeb, :controller

  def jwt_docs(conn, _params) do
    render(conn, "jwt_docs.html")
  end
end
