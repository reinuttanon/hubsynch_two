defmodule HubPaymentsWeb.SettingLive.Index do
  use HubPaymentsWeb, :live_view

  alias HubPayments.Shared
  alias HubPayments.Shared.Setting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :settings, list_settings())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Setting")
    |> assign(:setting, Shared.get_setting!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Setting")
    |> assign(:setting, %Setting{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Settings")
    |> assign(:setting, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    setting = Shared.get_setting!(id)
    case Shared.delete_setting(setting) do
    {:ok, _} ->
      {:noreply,
       socket
       |> put_flash(:info, "Setting deleted successfully")
       |> assign(:settings, list_settings())}

    {:error, _} ->
      {:noreply,
       socket
       |> put_flash(:error, "Setting must be inactive to delete")
       |> assign(:settings, list_settings())}
      end
  end

  defp list_settings do
    Shared.list_settings()
  end
end
