defmodule HubIdentityWeb.Api.V1.SupportController do
  @moduledoc false
  use HubIdentityWeb, :api_controller

  require Logger

  def certs(conn, _) do
    keys = HubIdentity.Encryption.public_keys()
    render(conn, "certs.json", %{keys: keys})
  end

  def test_redirect(conn, params) do
    auth = get_req_header(conn, "authorization")
    Logger.info(%{authorization: auth, params: params})

    conn
    |> send_resp(200, "ok")
    |> halt()
  end
end
