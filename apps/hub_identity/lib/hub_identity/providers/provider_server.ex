defmodule HubIdentity.Providers.ProviderServer do
  use GenServer

  alias HubCluster.MementoRepo
  alias HubIdentity.Providers
  alias HubIdentity.Providers.Oauth2Provider

  @table Oauth2Provider

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    MementoRepo.create_table(Oauth2Provider)
    seed_data()
    {:ok, %{}}
  end

  def seed do
    GenServer.cast(__MODULE__, :seed)
  end

  ## Server

  def handle_cast(:seed, _state) do
    seed_data()
    {:noreply, %{}}
  end

  defp seed_data do
    MementoRepo.clear(@table)

    Providers.list_active_provider_configs()
    |> Task.async_stream(fn provider_config ->
      Providers.create_oauth2_provider(provider_config)
    end)
    |> Enum.map(fn {:ok, result} -> result end)
  end
end
