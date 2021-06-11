defmodule HubIdentityWeb.ClientServiceControllerTest do
  use HubIdentityWeb.ConnCase

  alias HubIdentity.ClientServices

  setup :register_and_log_in_administrator

  @create_attrs %{
    deleted_at: ~D[2010-04-17],
    description: "some description",
    name: "some name",
    email_confirmation_redirect_url: "redirec/here",
    redirect_url: "some redirect_url",
    uid: "some uid",
    url: "some url"
  }
  @update_attrs %{
    deleted_at: ~D[2011-05-18],
    description: "some updated description",
    name: "some updated name",
    redirect_url: "some updated redirect_url",
    uid: "some updated uid",
    url: "some updated url"
  }
  @invalid_attrs %{
    deleted_at: nil,
    description: nil,
    name: nil,
    redirect_url: nil,
    uid: nil,
    url: nil
  }

  describe "index" do
    test "lists all client_services", %{conn: conn} do
      conn = get(conn, Routes.client_service_path(conn, :index))
      assert html_response(conn, 200) =~ "Client services"
    end
  end

  describe "new client_service" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.client_service_path(conn, :new))
      assert html_response(conn, 200) =~ "New Client service"
    end
  end

  describe "create client_service" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.client_service_path(conn, :create), client_service: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.client_service_path(conn, :show, id)

      conn = get(conn, Routes.client_service_path(conn, :show, id))
      assert html_response(conn, 200) =~ @create_attrs[:name]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.client_service_path(conn, :create), client_service: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Client service"
    end
  end

  describe "edit client_service" do
    setup [:create_client_service]

    test "renders form for editing chosen client_service", %{
      conn: conn,
      client_service: client_service
    } do
      conn = get(conn, Routes.client_service_path(conn, :edit, client_service))
      assert html_response(conn, 200) =~ "Edit Client service"
    end
  end

  describe "update client_service" do
    setup [:create_client_service]

    test "redirects when data is valid", %{conn: conn, client_service: client_service} do
      conn =
        put(conn, Routes.client_service_path(conn, :update, client_service),
          client_service: @update_attrs
        )

      assert redirected_to(conn) == Routes.client_service_path(conn, :show, client_service)

      conn = get(conn, Routes.client_service_path(conn, :show, client_service))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, client_service: client_service} do
      conn =
        put(conn, Routes.client_service_path(conn, :update, client_service),
          client_service: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Client service"
    end
  end

  describe "delete client_service" do
    setup [:create_client_service]

    test "deletes chosen client_service", %{conn: conn, client_service: client_service} do
      conn = delete(conn, Routes.client_service_path(conn, :delete, client_service))
      assert redirected_to(conn) == Routes.client_service_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.client_service_path(conn, :show, client_service))
      end
    end
  end

  defp create_client_service(%{administrator: administrator}) do
    {:ok, client_service} = ClientServices.create_client_service(@create_attrs, administrator)
    %{client_service: client_service}
  end
end
