defmodule HubPaymentsWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `HubPaymentsWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, HubPaymentsWeb.ProviderLive.FormComponent,
        id: @provider.id || :new,
        action: @live_action,
        provider: @provider,
        return_to: Routes.provider_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, HubPaymentsWeb.ModalComponent, modal_opts)
  end

  def types_list, do: HubPayments.Shared.Setting.types()

  def envs_list, do: HubPayments.Shared.Setting.envs()
end
