defmodule HubIdentityWeb.DashboardController do
  @moduledoc false

  use HubIdentityWeb, :controller

  alias HubIdentity.{ClientServices, Metrics, Providers}

  def index(conn, _params) do
    administrator = conn.assigns[:current_administrator]

    providers =
      Providers.list_active_provider_configs() |> Enum.map(fn provider -> provider.name end)

    metrics =
      case administrator.system do
        true -> get_system_metrics(providers)
        false -> get_admin_metrics(administrator, providers)
      end

    render(conn, "index.html", metrics)
  end

  defp get_system_metrics(providers) do
    hub_identity_users = Metrics.total_activities("self", %{type: "User.create"})

    provider_users =
      Enum.into(providers, %{}, fn name ->
        {name, Metrics.total_activities(name, %{type: "User.create"})}
      end)

    hub_identity_auths = Metrics.total_activities("self", %{type: "AccessToken.create"})

    provider_auths =
      Enum.into(providers, %{}, fn name ->
        {name, Metrics.total_activities(name, %{type: "AccessToken.create"})}
      end)

    %{
      hub_identity_users: hub_identity_users,
      provider_users: provider_users,
      hub_identity_auths: hub_identity_auths,
      provider_auths: provider_auths
    }
    |> totals()
  end

  defp get_admin_metrics(administrator, providers) do
    client_service_uids =
      ClientServices.list_client_services(%{administrator_id: administrator.id, uids: true})

    hub_identity_users =
      Metrics.total_activities("self", client_service_uids, %{type: "User.create"})

    provider_users =
      Enum.into(providers, %{}, fn name ->
        {name, Metrics.total_activities(name, client_service_uids, %{type: "User.create"})}
      end)

    hub_identity_auths =
      Metrics.total_activities("self", client_service_uids, %{type: "AccessToken.create"})

    provider_auths =
      Enum.into(providers, %{}, fn name ->
        {name, Metrics.total_activities(name, client_service_uids, %{type: "AccessToken.create"})}
      end)

    %{
      hub_identity_users: hub_identity_users,
      provider_users: provider_users,
      hub_identity_auths: hub_identity_auths,
      provider_auths: provider_auths
    }
    |> totals()
  end

  defp totals(
         %{
           hub_identity_users: hub_identity_users,
           provider_users: provider_users,
           hub_identity_auths: hub_identity_auths,
           provider_auths: provider_auths
         } = metrics
       ) do
    total_users = Enum.reduce(provider_users, 0, fn {_key, tot}, acc -> tot + acc end)

    total_auths = Enum.reduce(provider_auths, 0, fn {_key, tot}, acc -> tot + acc end)

    metrics
    |> Map.put(:total_users, total_users + hub_identity_users)
    |> Map.put(:total_auths, total_auths + hub_identity_auths)
  end
end
