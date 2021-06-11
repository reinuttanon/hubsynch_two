defmodule HubLedger.Ledgers.BuildValidator do
  alias HubLedger.Accounts
  alias HubLedger.Accounts.Account
  alias HubLedger.Ledgers.Transaction

  @doc """
  Validates that the transactions are balanced.

  ## Examples

      iex> validate_transactions_balance(transactions)
      [%Transactions{}, ...]

  """
  def validate_transactions_balance([]), do: {:error, "no transactions"}

  def validate_transactions_balance(transactions) when is_list(transactions) do
    transactions
    |> Enum.map(&changes(&1))
    |> Enum.group_by(& &1.kind)
    |> credit_debit_check()
  end

  @doc """
  Validates that the currency of the debits and credits transactions matches.

  ## Examples

      iex> validate_currencies_match(transactions)
      [%Transactions{}, ...]

  """
  def validate_currencies_match({:error, message}), do: {:error, message}

  def validate_currencies_match({:ok, changes}), do: validate_currencies_match(changes)

  def validate_currencies_match(transactions) when is_list(transactions) do
    transactions
    |> Enum.map(&changes(&1))
    |> Enum.map(&get_account(&1))
    |> verify_currencies()
  end

  @doc """
  Validates that the accounts are balanced.

  ## Examples

      iex> validate_transactions_balance(transactions)
      [%Accounts{}, ...]

  """
  def validate_accounts_balance({:error, message}), do: {:error, message}

  def validate_accounts_balance({:ok, changes}), do: validate_currencies_match(changes)

  def validate_accounts_balance(transactions) when is_list(transactions) do
    transactions
    |> Enum.map(&changes(&1))
    |> Enum.map(&get_account(&1))
    |> Enum.group_by(& &1.account.kind)
    |> account_credit_debit_check()
  end

  defp account_credit_debit_check(%{"credit" => credits, "debit" => debits}) do
    credit_account_total = Enum.group_by(credits, & &1.kind) |> credits_sum()
    debit_account_total = Enum.group_by(debits, & &1.kind) |> debits_sum()

    case Money.equals?(credit_account_total, debit_account_total) do
      true -> {:ok, credits ++ debits}
      _ -> {:error, "accounts do not balance"}
    end
  end

  defp account_credit_debit_check(_transactions), do: {:error, "accounts do not balance"}

  defp credits_sum(%{"credit" => credits, "debit" => debits}) do
    Money.subtract(sum(credits), sum(debits))
  end

  defp credits_sum(%{"credit" => credits}), do: sum(credits)

  defp credits_sum(%{"debit" => debits}), do: sum(debits)

  defp debits_sum(%{"credit" => credits, "debit" => debits}) do
    Money.subtract(sum(debits), sum(credits))
  end

  defp debits_sum(%{"credit" => credits}), do: sum(credits)

  defp debits_sum(%{"debit" => debits}), do: sum(debits)

  defp get_account(%{account: %Account{}} = transaction), do: transaction

  defp get_account(%{account_id: accout_id} = transaction) do
    with %Account{} = account <- Accounts.get_account!(accout_id) do
      Map.put(transaction, :account, account)
    end
  end

  defp changes(%Ecto.Changeset{changes: changes}), do: changes

  defp changes(%Transaction{} = transaction), do: Map.from_struct(transaction)

  defp changes(changes), do: changes

  defp credit_debit_check(%{"credit" => credits, "debit" => debits}) do
    case Money.equals?(sum(credits), sum(debits)) do
      true -> {:ok, credits ++ debits}
      _ -> {:error, "transactions do not balance"}
    end
  end

  defp credit_debit_check(_transactions), do: {:error, "transactions do not balance"}

  defp sum(transactions, accumulator \\ nil)

  defp sum([], accumulator), do: accumulator

  defp sum([%{money: %Money{currency: currency} = money} | transactions], nil) do
    accumulator =
      Money.new(0, currency)
      |> Money.add(money)

    sum(transactions, accumulator)
  end

  defp sum(
         [%{money: %Money{currency: currency} = money} | transactions],
         %Money{currency: currency} = accumulator
       ) do
    new_accumulator = Money.add(accumulator, money)

    sum(transactions, new_accumulator)
  end

  defp verify_currencies(transactions, return \\ [], currency \\ nil)

  defp verify_currencies([], return, _currency), do: {:ok, return}

  defp verify_currencies(
         [
           %{money: %Money{currency: currency}, account: %Account{currency: account_currency}} =
             transaction
           | transactions
         ],
         [],
         nil
       ) do
    case Money.Currency.get(currency) == Money.Currency.get(account_currency) do
      true -> verify_currencies(transactions, [transaction], currency)
      false -> {:error, "account currencies and transaction currencies mismatch"}
    end
  end

  defp verify_currencies(
         [
           %{money: %Money{currency: currency}, account: %Account{currency: account_currency}} =
             transaction
           | transactions
         ],
         return,
         currency
       ) do
    case Money.Currency.get(currency) == Money.Currency.get(account_currency) do
      true -> verify_currencies(transactions, [transaction | return], currency)
      false -> {:error, "account currencies and transaction currencies mismatch"}
    end
  end

  defp verify_currencies(_transactions, _return, _currency),
    do: {:error, "account currencies and transaction currencies mismatch"}
end
