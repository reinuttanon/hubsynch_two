defmodule HubIdentityWeb.ProviderConfigControllerTest do
  use HubIdentityWeb.ConnCase

  import HubIdentity.Factory

  setup :register_and_log_in_sys_administrator

  @create_attrs params_for(:provider_config)
  @update_attrs %{
    auth_url: "some updated auth_url",
    client_id: "some updated client_id",
    client_secret: "some updated client_secret",
    name: "some updated name",
    scopes: ""
  }
  @invalid_attrs %{
    auth_url: nil,
    client_id: nil,
    client_secret: nil,
    name: nil
  }

  describe "index" do
    test "lists all provider_config", %{conn: conn} do
      conn = get(conn, Routes.provider_config_path(conn, :index))
      assert html_response(conn, 200) =~ "Providers"
    end
  end

  describe "new provider_config" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.provider_config_path(conn, :new))
      assert html_response(conn, 200) =~ "New ProviderConfig"
    end
  end

  describe "create provider_config" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.provider_config_path(conn, :create), provider_config: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.provider_config_path(conn, :show, id)

      conn = get(conn, Routes.provider_config_path(conn, :show, id))
      assert html_response(conn, 200) =~ @create_attrs[:name] |> String.downcase()
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.provider_config_path(conn, :create), provider_config: @invalid_attrs)

      assert html_response(conn, 200) =~ "New ProviderConfig"
    end
  end

  describe "edit provider_config" do
    setup [:create_provider_config]

    test "renders form for editing chosen provider_config", %{
      conn: conn,
      provider_config: provider_config
    } do
      conn = get(conn, Routes.provider_config_path(conn, :edit, provider_config))
      assert html_response(conn, 200) =~ "Edit ProviderConfig"
    end
  end

  describe "update provider_config" do
    setup [:create_provider_config]

    test "redirects when data is valid", %{conn: conn, provider_config: provider_config} do
      conn =
        put(conn, Routes.provider_config_path(conn, :update, provider_config),
          provider_config: @update_attrs
        )

      assert redirected_to(conn) == Routes.provider_config_path(conn, :show, provider_config)

      conn = get(conn, Routes.provider_config_path(conn, :show, provider_config))
      assert html_response(conn, 200) =~ "some_updated_name"
    end

    test "renders errors when data is invalid", %{conn: conn, provider_config: provider_config} do
      conn =
        put(conn, Routes.provider_config_path(conn, :update, provider_config),
          provider_config: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit ProviderConfig"
    end
  end

  describe "delete provider_config" do
    setup [:create_provider_config]

    test "deletes chosen provider_config", %{conn: conn, provider_config: provider_config} do
      conn = delete(conn, Routes.provider_config_path(conn, :delete, provider_config))
      assert redirected_to(conn) == Routes.provider_config_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.provider_config_path(conn, :show, provider_config))
      end
    end
  end

  def create_provider_config(_) do
    provider_config = insert(:provider_config)
    %{provider_config: provider_config}
  end
end
