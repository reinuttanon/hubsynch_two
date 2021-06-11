defmodule HubIdentity.Providers do
  @moduledoc """
  The Oauth Providers context.
  """

  import Ecto.Query, warn: false

  alias HubIdentity.ClientServices.StateSecret
  alias HubIdentity.Providers.{Oauth2Backend, Oauth2Provider, ProviderConfig}
  alias HubIdentity.MementoRepo
  alias HubIdentity.Repo

  @doc """
  Returns the list of provider_configs.

  ## Examples

      iex> list_provider_configs()
      [%ProviderConfig{}, ...]

  """
  def list_provider_configs do
    Repo.all_present(ProviderConfig)
  end

  @doc """
  Returns the list of active provider_configs.

  ## Examples

      iex> list_provider_configs()
      [%ProviderConfig{}, ...]

  """
  def list_active_provider_configs do
    query =
      from p in ProviderConfig,
        where: p.active == true

    Repo.all_present(query)
  end

  @doc """
  Gets a single provider_config.

  Raises `Ecto.NoResultsError` if the ProviderConfig does not exist.

  ## Examples

      iex> get_provider_config!(123)
      %ProviderConfig{}

      iex> get_provider_config!(456)
      ** (Ecto.NoResultsError)

  """
  def get_provider_config!(id), do: Repo.get!(ProviderConfig, id)

  @doc """
  Creates a provider_config.

  ## Examples

      iex> create_provider_config(%{field: value})
      {:ok, %ProviderConfig{}}

      iex> create_provider_config(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_provider_config(attrs \\ %{}) do
    %ProviderConfig{}
    |> ProviderConfig.changeset(attrs)
    |> Repo.insert()
    |> update_oath_providers()
  end

  @doc """
  Updates a provider_config.

  ## Examples

      iex> update_provider_config(provider_config, %{field: new_value})
      {:ok, %ProviderConfig{}}

      iex> update_provider_config(provider_config, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_provider_config(%ProviderConfig{} = provider_config, attrs) do
    provider_config
    |> ProviderConfig.changeset(attrs)
    |> Repo.update()
    |> update_oath_providers()
  end

  @doc """
  Deletes a provider_config.

  ## Examples

      iex> delete_provider_config(provider_config)
      {:ok, %ProviderConfig{}}

      iex> delete_provider_config(provider_config)
      {:error, %Ecto.Changeset{}}

  """
  def delete_provider_config(%ProviderConfig{} = provider_config) do
    Repo.delete(provider_config)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking provider_config changes.

  ## Examples

      iex> change_provider_config(provider_config)
      %Ecto.Changeset{data: %ProviderConfig{}}

  """
  def change_provider_config(%ProviderConfig{} = provider_config, attrs \\ %{}) do
    ProviderConfig.changeset(provider_config, attrs)
  end

  def list_oauth_providers(%StateSecret{secret: secret}) do
    MementoRepo.all(Oauth2Provider)
    |> Enum.map(fn provider ->
      Oauth2Provider.update_request_url(provider, secret)
    end)
  end

  def get_provider_by_name(name) when is_binary(name) do
    case MementoRepo.get(Oauth2Provider, {:==, :name, name}) do
      {:ok, []} -> {:error, :provider_not_found}
      {:ok, [provider]} -> provider
    end
  end

  def get_provider_config_by_name(name) do
    Repo.get_by(ProviderConfig, name: name)
  end

  def parse_delete_request(%ProviderConfig{name: name} = provider_config, request) do
    provider_module = resolve_backend(name)
    provider_module.parse_delete_request(provider_config, request)
  end

  def create_oauth2_provider(%ProviderConfig{} = provider_config) do
    Oauth2Provider.create_changeset(provider_config)
    |> MementoRepo.insert()
  end

  def fetch_and_parse_tokens(%Oauth2Provider{id: id, name: name} = provider, code) do
    with %Oauth2Provider{} = updated_provider <- Oauth2Provider.update_token_url(provider, code),
         {:ok, token_response} <- Oauth2Backend.get_tokens(updated_provider),
         provider_module <- resolve_backend(name) do
      provider_module.parse_tokens(token_response, id)
    end
  end

  defp resolve_backend(name) do
    try do
      module = String.capitalize(name)
      String.to_existing_atom("Elixir.HubIdentity.Providers.#{module}")
    rescue
      e in ArgumentError -> {:error, e.message}
    end
  end

  defp update_oath_providers({:ok, %ProviderConfig{id: id, active: false} = provider_config}) do
    with %Oauth2Provider{} = provider <- MementoRepo.get_one(Oauth2Provider, id),
         :ok <- MementoRepo.delete(provider) do
      {:ok, provider_config}
    else
      nil -> {:ok, provider_config}
    end
  end

  defp update_oath_providers({:ok, %ProviderConfig{} = provider_config}) do
    with {:ok, _provider} <- create_oauth2_provider(provider_config) do
      {:ok, provider_config}
    end
  end

  defp update_oath_providers({:error, changeset}), do: {:error, changeset}
end
