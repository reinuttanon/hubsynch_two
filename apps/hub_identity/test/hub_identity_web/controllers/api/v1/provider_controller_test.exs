defmodule HubIdentityWeb.Api.V1.ProviderControllerTest do
  use HubIdentityWeb.ConnCase

  alias HubIdentity.{Metrics, Providers}

  import HubIdentity.Factory

  setup do
    client_service = HubIdentity.Factory.insert(:client_service, refresh_token: true)
    api_key = HubIdentity.Factory.insert(:api_key, type: "public", client_service: client_service)
    conn = build_api_conn(api_key.data)
    user = insert(:user)
    email = insert(:email, user: user, primary: true)

    %{
      conn: conn,
      user: user,
      email: email,
      client_service: client_service
    }
  end

  describe "authenticate/2" do
    test "with correct credentials returns jwt tokens", %{
      conn: conn,
      email: email
    } do
      response =
        post(conn, "/api/v1/providers/hub_identity", %{
          email: email.address,
          password: "LongPassword"
        })
        |> json_response(200)

      assert response["access_token"] != nil
      assert response["refresh_token"] != nil
    end

    test "with correct credentials creates a metric record", %{
      conn: conn,
      email: email,
      client_service: client_service
    } do
      assert Metrics.list_user_activities() == []

      post(conn, "/api/v1/providers/hub_identity", %{
        email: email.address,
        password: "LongPassword"
      })
      |> json_response(200)

      metric = Metrics.list_user_activities() |> hd()
      assert metric.client_service_uid == client_service.uid
      assert metric.owner_type == "User"
      assert metric.owner_uid != nil
      assert metric.provider == "self"
      assert metric.type == "AccessToken.create"
    end

    test "with incorrect credentials returns unauthorized", %{
      conn: conn,
      email: email
    } do
      error =
        post(conn, "/api/v1/providers/hub_identity", %{
          email: "nothere@aol.com",
          password: "password"
        })

      assert response(error, 400) =~ "bad request"

      error =
        post(conn, "/api/v1/providers/hub_identity", %{
          email: email.address,
          password: "WrongPassword"
        })

      assert response(error, 400) =~ "bad request"
    end
  end

  describe "providers/2" do
    test "returns a list of providers", %{conn: conn} do
      HubCluster.MementoRepo.clear(Oauth2Provider)

      for _ <- 1..3 do
        HubIdentity.Factory.insert(:provider_config) |> Providers.create_oauth2_provider()
      end

      response =
        get(conn, "/api/v1/providers")
        |> json_response(200)

      assert length(response) >= 3

      for provider <- response do
        assert provider["name"] != nil
        assert provider["request_url"] != nil
      end
    end
  end

  describe "token/2" do
    test "returns an access token with proper credentials and refresh_token", %{
      client_service: client_service,
      user: user
    } do
      api_key =
        HubIdentity.Factory.insert(:api_key, type: "private", client_service: client_service)

      {:ok, refresh_token, _} = HubIdentity.Encryption.Tokens.refresh_token(client_service, user)

      response =
        post(build_conn(), "/api/v1/providers/oauth/token", %{
          grant_type: "refresh_token",
          client_id: client_service.uid,
          client_secret: api_key.data,
          refresh_token: refresh_token
        })
        |> json_response(200)

      assert response["access_token"] != nil
      assert response["expires"] != nil
      assert response["scope"] == "hub_identity offline_access"
      assert response["token_type"] == "Bearer"
    end

    test "with invalid token returns error", %{
      client_service: client_service,
      user: user,
      email: email
    } do
      api_key =
        HubIdentity.Factory.insert(:api_key, type: "private", client_service: client_service)

      {:ok, access_token, _} =
        HubIdentity.Encryption.Tokens.access_token(client_service, user, email)

      error =
        post(build_conn(), "/api/v1/providers/oauth/token", %{
          grant_type: "refresh_token",
          client_id: client_service.uid,
          client_secret: api_key.data,
          refresh_token: access_token
        })
        |> response(400)

      assert error == "bad request"
    end

    test "with invalid key returns error", %{
      client_service: client_service,
      user: user
    } do
      api_key =
        HubIdentity.Factory.insert(:api_key, type: "public", client_service: client_service)

      {:ok, refresh_token, _} = HubIdentity.Encryption.Tokens.refresh_token(client_service, user)

      error =
        post(build_conn(), "/api/v1/providers/oauth/token", %{
          grant_type: "refresh_token",
          client_id: client_service.uid,
          client_secret: api_key.data,
          refresh_token: refresh_token
        })
        |> response(400)

      assert error == "bad request"
    end

    test "with invalid client uid returns error", %{
      client_service: client_service,
      user: user
    } do
      api_key =
        HubIdentity.Factory.insert(:api_key, type: "private", client_service: client_service)

      {:ok, refresh_token, _} = HubIdentity.Encryption.Tokens.refresh_token(client_service, user)

      other_client_service =
        HubIdentity.Factory.insert(:client_service, %{uid: "not-the-same-uid12345"})

      error =
        post(build_conn(), "/api/v1/providers/oauth/token", %{
          grant_type: "refresh_token",
          client_id: other_client_service.uid,
          client_secret: api_key.data,
          refresh_token: refresh_token
        })
        |> response(400)

      assert error == "bad request"
    end
  end

  defp build_api_conn(api_key) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key)
  end
end
