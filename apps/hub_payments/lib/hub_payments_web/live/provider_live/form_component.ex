defmodule HubPaymentsWeb.ProviderLive.FormComponent do
  use HubPaymentsWeb, :live_component

  alias HubPayments.Providers

  @impl true
  def update(%{provider: provider} = assigns, socket) do
    changeset = Providers.change_provider(provider)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"provider" => provider_params}, socket) do
    changeset =
      socket.assigns.provider
      |> Providers.change_provider(provider_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"provider" => provider_params}, socket) do
    save_provider(socket, socket.assigns.action, provider_params)
  end

  defp save_provider(socket, :edit, provider_params) do
    case Providers.update_provider(socket.assigns.provider, provider_params) do
      {:ok, _provider} ->
        {:noreply,
         socket
         |> put_flash(:info, "Provider updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_provider(socket, :new, provider_params) do
    case Providers.create_provider(provider_params) do
      {:ok, _provider} ->
        {:noreply,
         socket
         |> put_flash(:info, "Provider created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
