defmodule HubPaymentsWeb.ProviderLiveTest do
  use HubPaymentsWeb.ConnCase

  # import Phoenix.LiveViewTest

  # alias HubPayments.Providers

  # @create_attrs %{active: true, credentials: %{}, name: "some name", url: "some url", uuid: "some uuid"}
  # @update_attrs %{active: false, credentials: %{}, name: "some updated name", url: "some updated url", uuid: "some updated uuid"}
  # @invalid_attrs %{active: nil, credentials: nil, name: nil, url: nil, uuid: nil}

  # defp fixture(:provider) do
  #   {:ok, provider} = Providers.create_provider(@create_attrs)
  #   provider
  # end

  # defp create_provider(_) do
  #   provider = fixture(:provider)
  #   %{provider: provider}
  # end

  # describe "Index" do
  #   setup [:create_provider]

  #   test "lists all providers", %{conn: conn, provider: provider} do
  #     {:ok, _index_live, html} = live(conn, Routes.provider_index_path(conn, :index))

  #     assert html =~ "Listing Providers"
  #     assert html =~ provider.name
  #   end

  #   test "saves new provider", %{conn: conn} do
  #     {:ok, index_live, _html} = live(conn, Routes.provider_index_path(conn, :index))

  #     assert index_live |> element("a", "New Provider") |> render_click() =~
  #              "New Provider"

  #     assert_patch(index_live, Routes.provider_index_path(conn, :new))

  #     assert index_live
  #            |> form("#provider-form", provider: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     {:ok, _, html} =
  #       index_live
  #       |> form("#provider-form", provider: @create_attrs)
  #       |> render_submit()
  #       |> follow_redirect(conn, Routes.provider_index_path(conn, :index))

  #     assert html =~ "Provider created successfully"
  #     assert html =~ "some name"
  #   end

  #   test "updates provider in listing", %{conn: conn, provider: provider} do
  #     {:ok, index_live, _html} = live(conn, Routes.provider_index_path(conn, :index))

  #     assert index_live |> element("#provider-#{provider.id} a", "Edit") |> render_click() =~
  #              "Edit Provider"

  #     assert_patch(index_live, Routes.provider_index_path(conn, :edit, provider))

  #     assert index_live
  #            |> form("#provider-form", provider: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     {:ok, _, html} =
  #       index_live
  #       |> form("#provider-form", provider: @update_attrs)
  #       |> render_submit()
  #       |> follow_redirect(conn, Routes.provider_index_path(conn, :index))

  #     assert html =~ "Provider updated successfully"
  #     assert html =~ "some updated name"
  #   end

  #   test "deletes provider in listing", %{conn: conn, provider: provider} do
  #     {:ok, index_live, _html} = live(conn, Routes.provider_index_path(conn, :index))

  #     assert index_live |> element("#provider-#{provider.id} a", "Delete") |> render_click()
  #     refute has_element?(index_live, "#provider-#{provider.id}")
  #   end
  # end

  # describe "Show" do
  #   setup [:create_provider]

  #   test "displays provider", %{conn: conn, provider: provider} do
  #     {:ok, _show_live, html} = live(conn, Routes.provider_show_path(conn, :show, provider))

  #     assert html =~ "Show Provider"
  #     assert html =~ provider.name
  #   end

  #   test "updates provider within modal", %{conn: conn, provider: provider} do
  #     {:ok, show_live, _html} = live(conn, Routes.provider_show_path(conn, :show, provider))

  #     assert show_live |> element("a", "Edit") |> render_click() =~
  #              "Edit Provider"

  #     assert_patch(show_live, Routes.provider_show_path(conn, :edit, provider))

  #     assert show_live
  #            |> form("#provider-form", provider: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     {:ok, _, html} =
  #       show_live
  #       |> form("#provider-form", provider: @update_attrs)
  #       |> render_submit()
  #       |> follow_redirect(conn, Routes.provider_show_path(conn, :show, provider))

  #     assert html =~ "Provider updated successfully"
  #     assert html =~ "some updated name"
  #   end
  # end
end
