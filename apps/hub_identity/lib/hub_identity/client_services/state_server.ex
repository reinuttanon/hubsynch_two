defmodule HubIdentity.ClientServices.StateServer do
  @moduledoc false
  use GenServer

  require Logger

  alias HubIdentity.ClientServices.StateSecret
  alias HubCluster.MementoRepo

  @delete_interval 60_000
  @expire_milliseconds -600_000

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    HubCluster.MementoRepo.create_table(StateSecret)
    :timer.send_interval(@delete_interval, :delete_expired)

    {:ok, %{}}
  end

  def delete_expired(date) do
    GenServer.call(__MODULE__, {:delete_expired, date})
  end

  def handle_call({:delete_expired, date}, _from, state) do
    total = delete_secrets(date)
    {:reply, {:ok, "deleted: #{total} secrets"}, state}
  end

  def handle_info(:delete_expired, state) do
    DateTime.utc_now()
    |> DateTime.add(@expire_milliseconds, :millisecond)
    |> DateTime.to_unix()
    |> delete_secrets()

    {:noreply, state}
  end

  defp delete_secrets(date) do
    total =
      MementoRepo.get!(StateSecret, {:<, :created_at, date})
      |> Task.async_stream(fn record -> MementoRepo.delete(record) end)
      |> Enum.map(fn {:ok, result} -> result end)
      |> length()

    if total >= 1 do
      Logger.info("deleted: #{total} secrets")
    end

    total
  end
end
