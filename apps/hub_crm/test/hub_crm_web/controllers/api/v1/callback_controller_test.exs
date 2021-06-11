defmodule HubCrmWeb.Api.V1.CallbackControllerTest do
  use HubCrmWeb.ConnCase

  import HubCrm.HubsynchFactory

  describe "show/2" do
    test "returns the found user by email" do
      user = insert(:user)

      response =
        build_api_conn()
        |> get("/api/v1/callbacks/hub_identity?email=#{user.email}")
        |> json_response(200)

      assert response["owner_uid"] == user.user_id
      assert response["owner_type"] == "Hubsynch.User"
    end

    test "returns empty fields if no user" do
      response =
        build_api_conn()
        |> get("/api/v1/callbacks/hub_identity?email=nothere@hivelocity.co.jp")
        |> json_response(200)

      assert response["owner_uid"] == ""
      assert response["owner_type"] == ""
    end
  end

  defp build_api_conn do
    api_key = HubCrm.HubIdentityFactory.insert(:api_key)

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key.data)
  end
end
