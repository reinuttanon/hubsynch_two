defmodule HubPaymentsWeb.SettingLiveTest do
  use HubPaymentsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias HubPayments.Shared

  @create_attrs params_for(:setting)
  @update_attrs %{
    active: false,
    description: "some updated description",
    env: "staging",
    key: "some updated key",
    type: "file_path",
    value: "some updated value"
  }
  @invalid_attrs %{description: nil, env: nil, key: nil, type: nil, value: nil}

  defp fixture(:setting) do
    {:ok, setting} = Shared.create_setting(@create_attrs)
    setting
  end

  defp create_setting(_) do
    setting = fixture(:setting)
    %{setting: setting}
  end

  describe "Index" do
    setup [:create_setting]

    test "lists all settings", %{conn: conn, setting: setting} do
      {:ok, _index_live, html} = live(conn, Routes.setting_index_path(conn, :index))

      assert html =~ "Listing Settings"
    end

    test "saves new setting", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.setting_index_path(conn, :index))

      assert index_live |> element("a", "New Setting") |> render_click() =~
               "New Setting"

      assert_patch(index_live, Routes.setting_index_path(conn, :new))

      assert index_live
             |> form("#setting-form", setting: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, val, html} =
        index_live
        |> form("#setting-form",
          setting: %{
            active: true,
            env: "development",
            key: "some_key",
            description: "some description",
            type: "secret",
            value: "key_value"
          }
        )
        |> render_submit()
        |> follow_redirect(conn, Routes.setting_index_path(conn, :index))

      assert html =~ "Setting created successfully"
      assert html =~ "some description"
    end

    test "updates setting in listing", %{conn: conn, setting: setting} do
      {:ok, index_live, _html} = live(conn, Routes.setting_index_path(conn, :index))

      assert index_live |> element("#setting-#{setting.id} a", "Edit") |> render_click() =~
               "Edit Setting"

      assert_patch(index_live, Routes.setting_index_path(conn, :edit, setting))

      assert index_live
             |> form("#setting-form", setting: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#setting-form", setting: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.setting_index_path(conn, :index))

      assert html =~ "Setting updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes setting in listing", %{conn: conn, setting: setting} do
      {:ok, index_live, _html} = live(conn, Routes.setting_index_path(conn, :index))

      assert index_live |> element("#setting-#{setting.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#setting-#{setting.id}")
    end
  end

  describe "Show" do
    setup [:create_setting]

    test "displays setting", %{conn: conn, setting: setting} do
      {:ok, _show_live, html} = live(conn, Routes.setting_show_path(conn, :show, setting))

      assert html =~ "Show Setting"
      assert html =~ setting.key
    end

    test "updates setting within modal", %{conn: conn, setting: setting} do
      {:ok, show_live, _html} = live(conn, Routes.setting_show_path(conn, :show, setting))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Setting"

      assert_patch(show_live, Routes.setting_show_path(conn, :edit, setting))

      assert show_live
             |> form("#setting-form", setting: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#setting-form", setting: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.setting_show_path(conn, :show, setting))

      assert html =~ "Setting updated successfully"
      assert html =~ "some updated description"
    end
  end
end
