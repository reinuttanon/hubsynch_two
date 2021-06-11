defmodule HubPaymentsWeb.ProviderLive.Show do
  use HubPaymentsWeb, :live_view

  alias HubPayments.Providers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:provider, Providers.get_provider!(id))}
  end

  defp page_title(:show), do: "Show Provider"
  defp page_title(:edit), do: "Edit Provider"
end
