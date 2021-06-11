defmodule HubCrmWeb.Api.V1.SupportController do
  use HubCrmWeb, :api_controller

  def countries(conn, _) do
    countries = HubCrm.Countries.all()
    render(conn, "countries.json", %{countries: countries})
  end

  def test_redirect(conn, params) do
    auth = get_req_header(conn, "authorization")
    Logger.info(%{authorization: auth, params: params})

    conn
    |> send_resp(200, "ok")
    |> halt()
  end
end
