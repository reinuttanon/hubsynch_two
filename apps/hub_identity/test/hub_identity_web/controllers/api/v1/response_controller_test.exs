defmodule HubIdentityWeb.Api.V1.ResponseControllerTest do
  use HubIdentityWeb.ConnCase

  import HubIdentity.Factory

  alias HubIdentity.{ClientServices, Identities, MementoRepo, Metrics}
  alias HubIdentityWeb.Authentication.AccessCookiesServer
  alias HubIdentity.Verifications.EmailVerifyReference

  describe "response/2 with google and a confirmed email" do
    setup do
      {:ok, provider_config} =
        params_for(:provider_config, %{
          name: "google",
          access_token_url: "www.google.com"
        })
        |> HubIdentity.Providers.create_provider_config()

      %{provider_config: provider_config}
    end

    test "with valid state secret redirects to client service redirect_url" do
      %{
        client_service: client_service,
        conn: conn,
        state_secret: state_secret
      } = create_environment()

      response =
        conn
        |> get("/api/v1/providers/oauth/response/google?code=1234&state=#{state_secret.secret}")

      assert redirected_to(response, 302) =~
               "#{client_service.redirect_url}?user_token="

      assert %{"_hub_identity_access" => %{value: id}} = response.resp_cookies
      cookie = AccessCookiesServer.get_cookie(id)

      assert cookie.owner.email == "erin@hivelocity.co.jp"
      assert cookie.owner.authenticated_by == "google"
    end

    test "with valid state secret generates a user_activity" do
      %{
        client_service: client_service,
        conn: conn,
        state_secret: state_secret
      } = create_environment()

      assert Metrics.list_user_activities() == []

      response =
        conn
        |> get("/api/v1/providers/oauth/response/google?code=1234&state=#{state_secret.secret}")

      assert redirected_to(response, 302) =~
               "#{client_service.redirect_url}?user_token="

      user_activity = Metrics.list_user_activities() |> hd()

      assert user_activity.client_service_uid == client_service.uid
      assert user_activity.owner_type == "User"
      assert user_activity.owner_uid != nil
      assert user_activity.provider == "google"
      assert user_activity.type == "User.create"
    end
  end

  describe "response/2 with facebook and an unconfirmed email" do
    setup do
      {:ok, provider_config} =
        params_for(:provider_config, %{
          name: "facebook",
          access_token_url: "www.facebook.com"
        })
        |> HubIdentity.Providers.create_provider_config()

      %{provider_config: provider_config}
    end

    test "with valid state secret redirects to client service email confirmation redirect_url with email verify true" do
      %{
        conn: conn,
        state_secret: state_secret
      } = create_environment(%{email_confirmation_redirect_url: "/email/confirm/required"})

      response =
        conn
        |> get("/api/v1/providers/oauth/response/facebook?code=1234&state=#{state_secret.secret}")

      assert redirected_to(response, 302) =~
               "/email/confirm/required?email_verification_sent=true&email="
    end

    test "a verify email response generates a email verify reference" do
      %{
        client_service: client_service,
        conn: conn,
        state_secret: state_secret
      } = create_environment(%{email_confirmation_redirect_url: "/email/confirm/required"})

      assert MementoRepo.all(EmailVerifyReference) == []

      response =
        conn
        |> get("/api/v1/providers/oauth/response/facebook?code=1234&state=#{state_secret.secret}")

      assert redirected_to(response, 302) =~
               "/email/confirm/required?email_verification_sent=true&email="

      {:ok, [email_verify_reference]} =
        MementoRepo.get(EmailVerifyReference, {:==, :address, "sullymustycode@gmail.com"})

      assert email_verify_reference.client_service_uid == client_service.uid
      assert email_verify_reference.provider_info.provider == "facebook"
      assert email_verify_reference.provider_info.email == "sullymustycode@gmail.com"

      assert email_verify_reference.user == nil
    end

    test "with an exisiting identity but new email redirects to client service redirect_url with user_token",
         %{provider_config: provider_config} do
      %{
        client_service: client_service,
        conn: conn,
        state_secret: state_secret
      } = create_environment()

      user = insert(:user)

      insert(:identity, user: user, reference: "12345", provider_config: provider_config)

      response =
        conn
        |> get("/api/v1/providers/oauth/response/facebook?code=1234&state=#{state_secret.secret}")

      assert redirected_to(response, 302) =~
               "#{client_service.redirect_url}?user_token="

      assert %{"_hub_identity_access" => %{value: id}} = response.resp_cookies
      cookie = AccessCookiesServer.get_cookie(id)

      assert cookie.owner.uid == user.uid
      assert cookie.owner.authenticated_by == "facebook"

      {:ok, [email_verify_reference]} =
        MementoRepo.get(EmailVerifyReference, {:==, :address, "sullymustycode@gmail.com"})

      assert email_verify_reference.client_service_uid == client_service.uid
      assert email_verify_reference.provider_info.provider == "facebook"
      assert email_verify_reference.provider_info.email == "sullymustycode@gmail.com"

      assert email_verify_reference.user == nil
    end

    test "with an exisiting identity but new email creates an email verify reference",
         %{provider_config: provider_config} do
      %{
        client_service: client_service,
        conn: conn,
        state_secret: state_secret
      } = create_environment()

      user = insert(:user)

      insert(:identity, user: user, reference: "12345", provider_config: provider_config)

      conn
      |> get("/api/v1/providers/oauth/response/facebook?code=1234&state=#{state_secret.secret}")

      {:ok, [email_verify_reference]} =
        MementoRepo.get(EmailVerifyReference, {:==, :address, "sullymustycode@gmail.com"})

      assert email_verify_reference.client_service_uid == client_service.uid
      assert email_verify_reference.provider_info.provider == "facebook"
      assert email_verify_reference.provider_info.email == "sullymustycode@gmail.com"

      assert email_verify_reference.user == nil
    end
  end

  describe "delete_data/2 with facebook" do
    test "returns the facebook json response" do
      provider_config = insert(:provider_config, name: "facebook")
      identity = insert(:identity, reference: "218471", provider_config: provider_config)

      assert Metrics.list_user_activities() == []

      response =
        build_conn()
        |> post("/api/v1/providers/oauth/data_delete_request/facebook",
          signed_request: facebook_request()
        )
        |> json_response(200)

      assert response["url"] != nil
      assert response["confirmation_code"] != nil

      user_activity = Metrics.list_user_activities() |> hd()

      assert user_activity.owner_type == "Identity"
      assert user_activity.owner_uid == identity.uid
      assert user_activity.provider == "facebook"
      assert user_activity.type == "Identity.delete"
    end

    test "returns bad request if data was previoulsy deleted" do
      provider_config = insert(:provider_config, name: "facebook")
      insert(:identity, reference: "218471", provider_config: provider_config)

      {:ok, _data_deletion} = Identities.delete_user_data(provider_config, "218471")

      error =
        build_conn()
        |> post("/api/v1/providers/oauth/data_delete_request/facebook",
          signed_request: facebook_request()
        )

      assert response(error, 400) =~ "bad request"
    end
  end

  defp create_environment(client_service_attrs \\ %{}) do
    client_service = insert(:client_service, client_service_attrs)
    state_secret = ClientServices.create_state_secret!(client_service)

    %{
      conn: build_conn(),
      client_service: client_service,
      state_secret: state_secret
    }
  end

  defp facebook_request do
    # The following was reversed engineered from the Facebook docuemenation using the secret: "client_secret_shhhhhh!"
    # the data is:
    # %{
    #    algorithm: "HMAC-SHA256",
    #    expires: 1291840400,
    #    issued_at: 1291836800,
    #    user_id: "218471"
    # }
    "w5ZbbWP9yOwBA1uJZbc7-9gZok0O42U4i0yyvxXE_jY.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTE4NDA0MDAsImlzc3VlZF9hdCI6MTI5MTgzNjgwMCwidXNlcl9pZCI6IjIxODQ3MSJ9"
  end
end
