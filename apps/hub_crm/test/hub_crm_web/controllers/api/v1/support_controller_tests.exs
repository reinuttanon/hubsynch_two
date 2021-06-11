defmodule HubCrmWeb.Api.V1.HubsynchUsersControllerTest do
  use HubCrmWeb.ConnCase, async: true

  describe "countries/2" do
    test "returns a list of countries and codes" do
      response =
        build_api_conn()
        |> get("/api/v1/support/countries")
        |> json_response(200)

      country = hd(response)
      assert country["Object"] == "Country"
      assert country["name"] != nil
      assert country["alpha_3"] != nil
    end
  end

  defp build_api_conn do
    api_key = HubIdentity.Factory.insert(:api_key, type: "private")

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key.data)
  end
end
