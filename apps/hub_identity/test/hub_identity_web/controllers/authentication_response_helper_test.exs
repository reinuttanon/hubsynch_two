defmodule HubIdentityWeb.AuthenticationResponseHelperTest do
  use HubIdentityWeb.ConnCase

  import HubIdentity.Factory

  alias HubIdentity.Metrics
  alias HubIdentityWeb.AuthenticationResponseHelper

  describe "respond/3" do
    setup do
      client_service = insert(:client_service)
      user = insert(:user)

      %{
        conn: build_conn(),
        user: user,
        client_service: client_service
      }
    end

    test "redirects to the client_service redirect_url with a cookie", %{
      client_service: client_service,
      conn: conn,
      user: user
    } do
      redirect = AuthenticationResponseHelper.respond(conn, user, client_service, "self")
      %{"_hub_identity_access" => cookie} = redirect.resp_cookies

      assert redirected_to(redirect, 302) ==
               "#{client_service.redirect_url}?user_token=#{cookie[:value]}"

      assert cookie.max_age == 86400
      assert cookie.value != nil
    end

    test "creates a user_activity when a cookie is generated", %{
      client_service: client_service,
      conn: conn,
      user: user
    } do
      assert Metrics.list_user_activities() == []

      redirect = AuthenticationResponseHelper.respond(conn, user, client_service, "self")
      %{"_hub_identity_access" => cookie} = redirect.resp_cookies

      assert redirected_to(redirect, 302) ==
               "#{client_service.redirect_url}?user_token=#{cookie[:value]}"

      user_activity = Metrics.list_user_activities() |> hd()

      assert user_activity.client_service_uid == client_service.uid
      assert user_activity.owner_type == "User"
      assert user_activity.owner_uid == user.uid
      assert user_activity.provider == "self"
      assert user_activity.type == "AccessCookie.create"
    end
  end
end
