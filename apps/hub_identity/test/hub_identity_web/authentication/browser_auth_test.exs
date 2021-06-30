# defmodule HubIdentityWeb.Authentication.BrowserAuthTest do
#   use HubIdentityWeb.ConnCase, async: false

#   alias HubIdentity.Metrics
#   alias HubIdentityWeb.Authentication.AccessCookiesServer

#   import HubIdentity.Factory

#   setup do
#     HubCluster.MementoRepo.clear(HubIdentityWeb.Authentication.AccessCookie)

#     client_service = HubIdentity.Factory.insert(:client_service)
#     api_key = HubIdentity.Factory.insert(:api_key, type: "public", client_service: client_service)
#     user = insert(:user)
#     email = insert(:email, user: user, primary: true)

#     %{
#       api_key: api_key,
#       conn: build_conn(),
#       user: user,
#       email: email,
#       client_service: client_service
#     }
#   end

#   describe "cookie redirect" do
#     test "with a hub_identity access cookie redirects back to the client_service url", %{
#       api_key: api_key,
#       user: user,
#       client_service: client_service,
#       conn: conn
#     } do
#       {:ok, cookie} = AccessCookiesServer.create_cookie(user)

#       response =
#         conn
#         |> put_req_cookie("_hub_identity_access", cookie.id)
#         |> init_test_session(%{client_service: client_service})
#         |> get(Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))

#       assert redirected_to(response, 302) ==
#                "#{client_service.redirect_url}?user_token=#{cookie.id}"
#     end

#     test "with a hub_identity access cookie generates a user_activity", %{
#       api_key: api_key,
#       user: user,
#       client_service: client_service,
#       conn: conn
#     } do
#       {:ok, cookie} = AccessCookiesServer.create_cookie(user)

#       assert Metrics.list_user_activities() == []

#       response =
#         conn
#         |> put_req_cookie("_hub_identity_access", cookie.id)
#         |> init_test_session(%{client_service: client_service})
#         |> get(Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))

#       assert redirected_to(response, 302) ==
#                "#{client_service.redirect_url}?user_token=#{cookie.id}"

#       user_activity = Metrics.list_user_activities() |> hd()

#       assert user_activity.client_service_uid == client_service.uid
#       assert user_activity.owner_type == "User"
#       assert user_activity.owner_uid == user.uid
#       assert user_activity.provider == "self"
#       assert user_activity.type == "AccessCookie.redirect"
#     end

#     test "with an invalid hub_identity access cookie continues to login", %{
#       api_key: api_key,
#       conn: conn
#     } do
#       client_service = HubIdentity.Factory.insert(:client_service)

#       response =
#         conn
#         |> put_req_cookie("_hub_identity_access", "bad_cookie_id")
#         |> init_test_session(%{client_service: client_service})
#         |> get(Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))
#         |> html_response(200)

#       assert response =~ "Login with HubIdentity"
#       assert response =~ "Don't have a HubIdentity account?"
#     end

#     test "with no hub_identity acces cookie continues to login", %{conn: conn, api_key: api_key} do
#       response =
#         get(conn, Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))
#         |> html_response(200)

#       assert response =~ "Login with HubIdentity"
#       assert response =~ "Don't have a HubIdentity account?"
#     end
#   end
# end
