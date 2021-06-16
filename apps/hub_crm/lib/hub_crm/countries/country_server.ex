defmodule HubCrm.Countries.CountryServer do
  use GenServer

  alias HubCrm.Countries.Country

  @table :countries

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    :ets.new(@table, [
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])

    seed_data()
    {:ok, %{}}
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def get_country_by_code(<<code::binary-size(2)>>) do
    GenServer.call(__MODULE__, {:get_country, :alpha_2, code})
  end

  def get_country_by_code(<<code::binary-size(3)>>) do
    GenServer.call(__MODULE__, {:get_country, :alpha_3, code})
  end

  def get_country_by_code(_), do: nil

  def seed do
    GenServer.cast(__MODULE__, :seed)
  end

  ## Server

  def handle_call(:all, _from, _state) do
    countries =
      :ets.tab2list(@table)
      |> Task.async_stream(fn country -> Country.build(country) end)
      |> Enum.map(fn {:ok, country} -> country end)

    {:reply, countries, %{}}
  end

  def handle_call({:get_country, :alpha_2, code}, _from, _state) do
    country =
      :ets.match_object(@table, {:_, code, :_, :_, :_, :_})
      |> Country.build()

    {:reply, country, %{}}
  end

  def handle_call({:get_country, :alpha_3, code}, _from, _state) do
    country =
      :ets.lookup(@table, code)
      |> Country.build()

    {:reply, country, %{}}
  end

  def handle_cast(:seed, _state) do
    seed_data()
    {:noreply, %{}}
  end

  defp seed_data do
    :ets.delete_all_objects(@table)

    Path.expand("../../../priv/repo/countries.txt", __DIR__)
    |> File.read!()
    |> Jason.decode!()
    |> Task.async_stream(fn country -> create(country) end)
    |> Enum.map(fn {:ok, result} -> result end)
  end

  defp create(country) do
    record = Country.build(country)
    :ets.insert(@table, record)
  end
end

# "apps/hub_crm/priv/repo/countries.txt"
