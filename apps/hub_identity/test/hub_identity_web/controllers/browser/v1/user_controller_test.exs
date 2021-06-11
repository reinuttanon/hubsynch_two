defmodule HubIdentityWeb.Browser.V1.UserControllerTest do
  use HubIdentityWeb.ConnCase

  alias HubIdentity.MementoRepo
  alias HubIdentity.Verifications.EmailVerifyReference

  setup do
    client_service = HubIdentity.Factory.insert(:client_service)
    api_key = HubIdentity.Factory.insert(:api_key, type: "public", client_service: client_service)

    %{
      api_key: api_key,
      conn: build_conn(),
      client_service: client_service
    }
  end

  describe "new/2" do
    test "with client_service in session renders new form", %{
      api_key: api_key,
      conn: conn
    } do
      session_conn =
        get(conn, Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))

      response =
        get(session_conn, Routes.browser_v1_user_path(conn, :new))
        |> html_response(200)

      assert response =~ "Register with HubIdentity"
    end

    test "without client_service in session returns 404", %{conn: conn} do
      response =
        get(conn, Routes.browser_v1_user_path(conn, :new))
        |> html_response(404)

      assert response =~ "Not Found"
    end
  end

  describe "create/2" do
    test "with valid information redirects to email verify page", %{
      api_key: api_key,
      conn: conn
    } do
      session_conn =
        get(conn, Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))

      response =
        post(session_conn, Routes.browser_v1_user_path(conn, :create),
          user: %{
            email: "erinp+1@hivelocity.co.jp",
            password: "LongPassword",
            password_confirmation: "LongPassword"
          }
        )

      assert redirected_to(response) == Routes.browser_v1_user_path(response, :email_verification)
    end

    test "with invalid data returns changeset errors", %{conn: conn, api_key: api_key} do
      session_conn =
        get(conn, Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))

      response =
        post(session_conn, Routes.browser_v1_user_path(conn, :create),
          user: %{
            email: "",
            password: "nope",
            password_confirmation: ""
          }
        )

      assert html_response(response, 200) =~ "Register with HubIdentity"
    end

    test "creates a user email verify reference", %{
      conn: conn,
      api_key: api_key
    } do
      session_conn =
        get(conn, Routes.browser_v1_provider_path(conn, :providers, api_key: api_key.data))

      post(session_conn, Routes.browser_v1_user_path(conn, :create),
        user: %{
          email: "erinp+1@hivelocity.co.jp",
          password: "LongPassword",
          password_confirmation: "LongPassword"
        }
      )

      {:ok, [email_verify_reference]} =
        MementoRepo.get(EmailVerifyReference, [{:==, :address, "erinp+1@hivelocity.co.jp"}])

      assert email_verify_reference.user.valid?
      assert email_verify_reference.user.changes.hashed_password != nil
      assert email_verify_reference.user.changes.password_confirmation == "LongPassword"
    end
  end
end
