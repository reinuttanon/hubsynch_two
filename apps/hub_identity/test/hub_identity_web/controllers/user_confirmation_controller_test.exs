defmodule HubIdentityWeb.UserConfirmationControllerTest do
  use HubIdentityWeb.ConnCase, async: false

  alias HubCluster.MementoRepo
  alias HubIdentity.{Identities, Verifications}
  alias HubIdentity.Verifications.EmailVerifyReference
  alias HubIdentityWeb.Authentication.AccessCookiesServer

  import HubIdentity.Factory

  describe "GET /users/confirm/:token" do
    test "confirms the given token once and redirects to the redirect_url" do
      client_service = insert(:client_service, redirect_url: "email_confirmation_url")

      conn = build_conn()

      address = "erin@hivelocity.co.jp"

      {:ok, email_verify} =
        Verifications.create_email_verify_reference(
          %{
            address: address,
            password: valid_user_password()
          },
          client_service
        )

      response = get(conn, Routes.user_confirmation_path(conn, :confirm, email_verify.reference))

      assert redirected_to(response) =~ "email_confirmation_url?user_token="
      assert %{"_hub_identity_access" => %{value: id}} = response.resp_cookies
      cookie = AccessCookiesServer.get_cookie(id)
      assert cookie.owner.email == address
      assert cookie.owner.authenticated_by == "HubIdentity"

      email = Identities.get_email(%{address: address})
      user = Identities.get_user!(email.user_id)

      assert email.confirmed_at != nil
      assert email.primary
      assert email.uid != nil

      assert user.uid != nil
      assert user.hashed_password != nil

      assert nil == MementoRepo.get_one(EmailVerifyReference, email_verify.id)
    end

    test "confirms the given token once and redirects to complete without redirect_url" do
      client_service = insert(:client_service, redirect_url: "")
      conn = build_conn()

      address = "erin@hivelocity.co.jp"

      {:ok, email_verify} =
        Verifications.create_email_verify_reference(
          %{
            address: address,
            password: valid_user_password()
          },
          client_service
        )

      conn = get(conn, Routes.user_confirmation_path(conn, :confirm, email_verify.reference))

      assert redirected_to(conn) == "/public_users/complete"
      assert get_flash(conn, :info) =~ "Account confirmed successfully"

      email = Identities.get_email(%{address: address})
      user = Identities.get_user!(email.user_id)

      assert email.confirmed_at != nil
      assert email.primary
      assert email.uid != nil

      assert user.uid != nil
      assert user.hashed_password != nil

      assert nil == MementoRepo.get_one(EmailVerifyReference, email_verify.id)
    end
  end
end
