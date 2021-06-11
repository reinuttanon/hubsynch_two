defmodule HubPaymentsWeb.ProviderLive.Index do
  use HubPaymentsWeb, :live_view

  alias HubPayments.Providers
  alias HubPayments.Providers.Provider

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :providers, list_providers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Provider")
    |> assign(:provider, Providers.get_provider!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Provider")
    |> assign(:provider, %Provider{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Providers")
    |> assign(:provider, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    provider = Providers.get_provider!(id)
    {:ok, _} = Providers.delete_provider(provider)

    {:noreply, assign(socket, :providers, list_providers())}
  end

  defp list_providers do
    Providers.list_providers()
  end
end
