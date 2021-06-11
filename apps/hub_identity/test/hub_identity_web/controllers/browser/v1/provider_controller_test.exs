defmodule HubIdentityWeb.Browser.V1.ProviderControllerTest do
  use HubIdentityWeb.ConnCase

  alias HubIdentity.Providers
  alias HubIdentityWeb.Authentication.AccessCookiesServer

  import HubIdentity.Factory

  setup do
    client_service = insert(:client_service)
    api_key = insert(:api_key, type: "public", client_service: client_service)
    user = insert(:user)
    email = insert(:confirmed_email, user: user)

    %{
      api_key: api_key,
      conn: build_conn(),
      user: user,
      email: email,
      client_service: client_service
    }
  end

  describe "authenticate/2" do
    test "with correct credentials returns jwt tokens", %{
      api_key: api_key,
      conn: conn,
      email: email,
      client_service: client_service
    } do
      session_conn =
        get(conn, Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))

      response =
        post(session_conn, Routes.browser_v1_provider_path(conn, :authenticate), %{
          email: email.address,
          password: valid_user_password()
        })

      assert redirected_to(response, 302) =~ "#{client_service.redirect_url}?user_token="
      assert %{"_hub_identity_access" => %{value: id}} = response.resp_cookies
      cookie = AccessCookiesServer.get_cookie(id)
      assert cookie.owner.email == email.address
      assert cookie.owner.authenticated_by == "HubIdentity"
    end

    test "with valid cookie returns", %{
      api_key: api_key,
      user: user,
      client_service: client_service,
      conn: conn
    } do
      {:ok, cookie} = AccessCookiesServer.create_cookie(user)

      response =
        conn
        |> put_req_cookie("_hub_identity_access", cookie.id)
        |> init_test_session(%{client_service: client_service})
        |> get(Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))

      assert redirected_to(response, 302) ==
               "#{client_service.redirect_url}?user_token=#{cookie.id}"
    end

    test "with incorrect credentials redirects to providers path", %{
      api_key: api_key,
      conn: conn,
      email: email
    } do
      session_conn =
        get(conn, Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))

      error =
        post(session_conn, Routes.browser_v1_provider_path(conn, :authenticate), %{
          email: "nothere@aol.com",
          password: "password"
        })
        |> redirected_to(302)

      assert error =~ "/browser/v1/providers?api_key=#{URI.encode_www_form(api_key.data)}"

      error =
        post(session_conn, "/browser/v1/providers/hub_identity", %{
          email: email.address,
          password: "WrongPassword"
        })
        |> redirected_to(302)

      assert error =~ "/browser/v1/providers?api_key=#{URI.encode_www_form(api_key.data)}"
    end

    test "without client service in session will return 404", %{conn: conn, email: email} do
      response =
        post(conn, "/browser/v1/providers/hub_identity", %{
          email: email.address,
          password: valid_user_password()
        })
        |> html_response(404)

      assert response =~ "Not Found"
    end
  end

  describe "providers/2" do
    test "returns a list of providers", %{api_key: api_key, conn: conn} do
      for _ <- 1..3 do
        HubIdentity.Factory.insert(:provider_config) |> Providers.create_oauth2_provider()
      end

      response =
        get(conn, Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))
        |> html_response(200)

      assert response =~ "Login with HubIdentity"
      assert response =~ "Don't have a HubIdentity account?"
    end
  end
end
