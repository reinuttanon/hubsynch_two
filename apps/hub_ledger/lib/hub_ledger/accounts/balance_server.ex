defmodule HubLedger.Accounts.BalanceServer do
  @moduledoc """
  Ensure running balances are accurate.

  There is a tiny risk that balances could get out of sync
  with transactions if there are too many concurrent transactions.

  This server is designed to run based on @old_seconds setting.
  Balances which are older than @recent_seconds and newer than
  @old_seconds will get updated with the current balance
  computed by summing all transactions.
  """

  use GenServer

  require Logger

  import Ecto.Query, warn: false

  alias HubLedger.Accounts.Balance
  alias HubLedger.{Accounts, Ledgers, Repo}

  # ten seconds
  @recent_seconds 10
  # two minutes
  @old_seconds 120

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(stack) do
    schedule_verfy_balances()
    {:ok, stack}
  end

  def verfy_balances do
    GenServer.call(__MODULE__, :verfy_balances)
  end

  @impl true
  def handle_call(:verfy_balances, _from, state) do
    result = verify_and_update_balances()

    {:reply, result, state}
  end

  @impl true
  def handle_info(:verfy_balances, state) do
    verify_and_update_balances()

    schedule_verfy_balances()

    {:noreply, state}
  end

  defp schedule_verfy_balances do
    Process.send_after(self(), :verfy_balances, @old_seconds * 1000)
  end

  defp get_balances_query(active, inactive) do
    from b in Balance,
      where: b.updated_at <= ^active and b.updated_at >= ^inactive
  end

  defp verify_and_update_balances do
    query = get_balances_query(too_recent_date(), too_old_date())

    Repo.transaction(
      fn ->
        query
        |> Repo.stream()
        |> Stream.each(fn balance -> verify_and_update_balance(balance) end)
        |> Stream.run()
      end,
      timeout: :infinity
    )
  end

  defp verify_and_update_balance(
         %Balance{
           account_id: account_id,
           kind: kind,
           money: %Money{amount: amount, currency: currency}
         } = balance
       ) do
    total = sum_transactions(%{account_id: account_id, kind: kind})

    case total == amount do
      true -> {:ok, balance}
      false -> update_and_log(balance, Money.new(total, currency))
    end
  end

  defp update_and_log(
         %Balance{uuid: uuid, money: %Money{amount: old_amount}} = balance,
         new_money
       ) do
    with {:ok, %Balance{money: %Money{amount: new_amount}} = new_balance} <-
           Accounts.update_balance(balance, new_money) do
      Logger.info("updated balance #{uuid} from: #{old_amount} to: #{new_amount}")

      {:ok, new_balance}
    else
      {:error, _message} -> Logger.alert("failed to update balance #{balance.uuid}")
    end
  end

  defp too_recent_date do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
    |> NaiveDateTime.add(-@recent_seconds, :second)
  end

  defp too_old_date do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
    |> NaiveDateTime.add(-(@old_seconds + @recent_seconds), :second)
  end

  defp sum_transactions(%{account_id: id, kind: kind}) do
    credits = Ledgers.sum_transactions(%{account_id: id, kind: "credit"})
    debits = Ledgers.sum_transactions(%{account_id: id, kind: "debit"})

    case kind do
      "credit" -> credits - debits
      "debit" -> debits - credits
    end
  end
end
