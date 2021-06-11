defmodule HubIdentityWeb.ProviderConfigController do
  @moduledoc false
  alias HubIdentity.Providers
  alias HubIdentity.Providers.ProviderConfig

  use HubIdentityWeb, :controller

  def index(conn, _params) do
    provider_configs = Providers.list_provider_configs()
    render(conn, "index.html", provider_configs: provider_configs)
  end

  def new(conn, _params) do
    changeset = Providers.change_provider_config(%ProviderConfig{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"provider_config" => provider_config_params}) do
    case Providers.create_provider_config(provider_config_params) do
      {:ok, provider_config} ->
        conn
        |> put_flash(:info, "ProviderConfig created successfully.")
        |> redirect(to: Routes.provider_config_path(conn, :show, provider_config))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    provider_config = Providers.get_provider_config!(id)
    render(conn, "show.html", provider_config: provider_config)
  end

  def edit(conn, %{"id" => id}) do
    provider_config = Providers.get_provider_config!(id)
    changeset = Providers.change_provider_config(provider_config)
    render(conn, "edit.html", provider_config: provider_config, changeset: changeset)
  end

  def update(conn, %{"id" => id, "provider_config" => provider_config_params}) do
    provider_config = Providers.get_provider_config!(id)

    case Providers.update_provider_config(provider_config, provider_config_params) do
      {:ok, provider_config} ->
        conn
        |> put_flash(:info, "ProviderConfig updated successfully.")
        |> redirect(to: Routes.provider_config_path(conn, :show, provider_config))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", provider_config: provider_config, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    provider_config = Providers.get_provider_config!(id)
    {:ok, _provider_config} = Providers.delete_provider_config(provider_config)

    conn
    |> put_flash(:info, "ProviderConfig deleted successfully.")
    |> redirect(to: Routes.provider_config_path(conn, :index))
  end
end
