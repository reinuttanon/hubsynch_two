defmodule HubIdentity.ClientServices.WebhooksTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.ClientServices.Webhooks

  describe "get_user/2" do
    test "returns a json body from the client_service webhook_url" do
      client_service = insert(:webhook_client_service)
      address = "erin@hivelocity.co.jp"
      {:ok, response} = Webhooks.get_user(client_service, address)
      assert response == %{owner_type: "HubsynchV2.User", owner_uid: "12345"}
    end

    test "when uid are integer parse to strings" do
      client_service = insert(:webhook_client_service)
      address = "erin123@hivelocity.co.jp"
      {:ok, response} = Webhooks.get_user(client_service, address)
      assert response == %{owner_type: "Hubsynch.User", owner_uid: "38185"}
    end

    test "returns nil owner if user not found response" do
      client_service = insert(:webhook_client_service)

      assert {:ok, %{owner_type: "", owner_uid: ""}} ==
               Webhooks.get_user(client_service, "other@email.co.jp")

      assert {:ok, %{owner_type: "", owner_uid: ""}} ==
               Webhooks.get_user(client_service, "null@email.co.jp")
    end

    test "returns nil owner if client_service does not have valid webhook" do
      address = "erin@hivelocity.co.jp"

      no_auth_key = insert(:webhook_client_service, %{webhook_auth_key: ""})
      assert {:ok, %{owner_type: "", owner_uid: ""}} == Webhooks.get_user(no_auth_key, address)

      nil_auth_key = insert(:webhook_client_service, %{webhook_auth_key: nil})
      assert {:ok, %{owner_type: "", owner_uid: ""}} == Webhooks.get_user(nil_auth_key, address)

      no_auth_type = insert(:webhook_client_service, %{webhook_auth_type: ""})
      assert {:ok, %{owner_type: "", owner_uid: ""}} == Webhooks.get_user(no_auth_type, address)

      nil_auth_type = insert(:webhook_client_service, %{webhook_auth_type: nil})
      assert {:ok, %{owner_type: "", owner_uid: ""}} == Webhooks.get_user(nil_auth_type, address)

      no_url = insert(:webhook_client_service, %{webhook_url: ""})
      assert {:ok, %{owner_type: "", owner_uid: ""}} == Webhooks.get_user(no_url, address)

      nil_url = insert(:webhook_client_service, %{webhook_url: nil})
      assert {:ok, %{owner_type: "", owner_uid: ""}} == Webhooks.get_user(nil_url, address)
    end
  end
end
