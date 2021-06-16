defmodule HubPayments.Shared.SettingServer do
  @moduledoc false
  use GenServer

  require Logger

  alias HubPayments.Shared
  alias HubPayments.Shared.{Setting, SettingRecord}

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    create_table(SettingRecord)

    for setting <- Shared.list_settings() do
      setting
      |> SettingRecord.create_changeset()
      |> insert_setting()
    end

    {:ok, %{}}
  end

  def list_settings do
    GenServer.call(__MODULE__, :list_settings)
  end

  def get_setting(key, env) do
    GenServer.call(__MODULE__, {:get_setting, key, env})
  end

  def insert({:ok, %Setting{active: true} = setting}) do
    GenServer.cast(__MODULE__, {:insert, setting})
    {:ok, setting}
  end

  def insert({:ok, %Setting{active: false, key: key, env: env} = setting}) do
    GenServer.cast(__MODULE__, {:delete, key, env})
    {:ok, setting}
  end

  def insert(setting), do: setting

  def handle_cast({:insert, setting}, state) do
    setting
    |> SettingRecord.create_changeset()
    |> insert_setting()

    {:noreply, state}
  end

  def handle_cast({:delete, key, env}, state) do
    query = [
      {:==, :key, key},
      {:==, :env, env}
    ]

    {:ok, records} =
      Memento.transaction(fn ->
        Memento.Query.select(SettingRecord, query)
      end)

    Enum.each(records, &delete_record(&1))
    {:noreply, state}
  end

  def handle_call(:list_settings, _from, state) do
    records =
      Memento.transaction!(fn ->
        Memento.Query.all(SettingRecord)
      end)

    {:reply, {:ok, records}, state}
  end

  def handle_call({:get_setting, key, env}, _from, state) do
    query = [
      {:==, :key, key},
      {:==, :env, env}
    ]

    {:ok, records} =
      Memento.transaction(fn ->
        Memento.Query.select(SettingRecord, query)
      end)

    {:reply, List.first(records), state}
  end

  defp insert_setting(object) do
    Memento.transaction(fn ->
      Memento.Query.write(object)
    end)
  end

  defp create_table(table, opts \\ []) do
    case Memento.Table.create(table, opts) do
      :ok -> :ok
      {:error, {:already_exists, _}} -> :ok
      # log this in future
      {:error, msg} -> {:error, msg}
    end
  end

  defp delete_record(object) do
    Memento.transaction!(fn ->
      Memento.Query.delete_record(object)
    end)
  end
end
