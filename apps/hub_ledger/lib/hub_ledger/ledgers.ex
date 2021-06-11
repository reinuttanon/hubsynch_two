defmodule HubLedger.Ledgers do
  @moduledoc """
  The Ledgers context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias HubLedger.{Accounts, Repo}
  alias HubLedger.Accounts.Balance
  alias HubLedger.Ledgers.{BuildParser, BuildValidator, Entry, EntryBuilder, Transaction}
  alias HubLedger.Reports.{EntryFilters, TransactionFilters}

  @doc """
  Creates a Journal entry from a Payload and an entry_builder_uid. It looks for an Entry Builder
  and builds the entry and transactions to generate the journal entry.
  It will return the entry and the executed Transactions.

  ## Examples

      iex> create_journal_entry(payload, entry_builder_uuid)
      {:ok, %{entry: %Entry{}, transactions: {4, [%Transaction{}]}}}

  """
  def create_journal_entry(payload, entry_builder_uuid) do
    with %EntryBuilder{} = builder <- get_entry_builder(%{uuid: entry_builder_uuid}),
         {:ok, entry, transactions} <- BuildParser.build(payload, builder),
         {:ok, results} <- journal_entry(entry, transactions) do
      after_create_verify_and_balance_transactions(results)
    else
      nil -> {:error, "invalid entry builder"}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Creates a Journal entry from a Payload and an entry_builder_uid. It looks for an Entry Builder
  and builds the entry and transactions to generate the journal entry.
  It will return the entry and the executed Transactions.

  ## Examples

      iex> safe_journal_entry(payload, entry_builder_uuid)
      {:ok, %{entry: %Entry{}, transactions: {4, [%Transaction{}]}}}

      iex> safe_journal_entry(payload, invalid_entry_builder_uuid)
      {:error, "invalid entry builder"}

  """
  def safe_journal_entry(payload, entry_builder_uuid) do
    with %EntryBuilder{} = builder <- get_entry_builder(%{uuid: entry_builder_uuid}),
         {:ok, entry, transactions} <- BuildParser.build(payload, builder),
         {:ok, _} <- verify_and_balance_transactions(transactions) do
      journal_entry(entry, transactions)
    else
      nil -> {:error, "invalid entry builder"}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Creates a Journal entry from an entry changeset and transaction changesets.
  If it gets a map instead of a changeset, will generate an changeset from it.
  If the entry or any Transaction is invalid. Returns those invalids changesets.
  ## Examples

      iex> journal_entry(%Ecto.Changeset{entry}, [%Ecto.Changeset{transaction}])
      {:ok, %{entry: %Entry{}, transactions: {4, [%Transaction{}]}}}

      iex> journal_entry(invalid_entry, [invalid_transaction])
      {:error, %{entry: %Entry{}, transactions: {[%Transaction{}]}}}

  """
  def journal_entry(%Ecto.Changeset{} = entry, transactions) when is_list(transactions) do
    with true <- entry.valid?,
         true <- Enum.all?(transactions, & &1.valid?) do
      journal_entry_multi(entry, transactions)
    else
      false -> return_invalid_changeset(entry, transactions)
    end
  end

  def journal_entry(entry, transactions) when is_map(entry) and is_list(transactions) do
    entry_changeset = Entry.create_changeset(entry)

    transaction_changeset =
      Enum.map(transactions, fn transaction -> Transaction.create_changeset(transaction) end)

    journal_entry(entry_changeset, transaction_changeset)
  end

  def journal_entry(_, _), do: {:error, "unknown journal entry failure"}

  @doc """
  Returns the list of entries.

  ## Examples

      iex> list_entries()
      [%Entry{}, ...]

  """
  def list_entries do
    Entry
    |> EntryFilters.order_by("asc")
    |> EntryFilters.limit(10)
    |> Repo.all()
  end

  def get_entry(%{uuid: uuid}) do
    query =
      from e in Entry,
        where: e.uuid == ^uuid

    Repo.one(query)
  end

  @doc """
  Gets a single entry.

  Raises `Ecto.NoResultsError` if the Entry does not exist.

  ## Examples

      iex> get_entry!(123)
      %Entry{}

      iex> get_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_entry!(id), do: Repo.get!(Entry, id) |> Repo.preload([:transactions])

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Transaction
    |> TransactionFilters.order_by("asc")
    |> TransactionFilters.limit(10)
    |> Repo.all()
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id) |> Repo.preload([:account, :entry])

  @doc """
  This will fail hard if you send it params that are not in TransactionFilters.
  There must be a kind in order to determine credit or debit.
  """
  def sum_transactions(%{kind: _kind} = params) do
    sum =
      Enum.reduce(params, Transaction, fn {key, value}, acc ->
        apply(TransactionFilters, key, [acc, value])
      end)
      |> TransactionFilters.sum()
      |> Repo.one()

    case sum do
      nil -> 0
      %Decimal{} = decimal -> Decimal.to_integer(decimal)
      amount -> amount
    end
  end

  @doc """
  Returns the list of entry_builders.

  ## Examples

      iex> list_entry_builders()
      [%EntryBuilder{}, ...]

  """
  def list_entry_builders do
    Repo.all(EntryBuilder)
  end

  @doc """
  Gets a single entry_builder.

  Raises `Ecto.NoResultsError` if the Entry builder does not exist.

  ## Examples

      iex> get_entry_builder!(123)
      %EntryBuilder{}

      iex> get_entry_builder!(456)
      ** (Ecto.NoResultsError)

  """
  def get_entry_builder!(id), do: Repo.get!(EntryBuilder, id)

  def get_entry_builder(%{uuid: uuid}) do
    query =
      from eb in EntryBuilder,
        where: eb.uuid == ^uuid

    Repo.one(query)
  end

  @doc """
  Creates a entry_builder.

  ## Examples

      iex> create_entry_builder(%{field: value})
      {:ok, %EntryBuilder{}}

      iex> create_entry_builder(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entry_builder(attrs \\ %{}) do
    %EntryBuilder{}
    |> EntryBuilder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a entry_builder.

  ## Examples

      iex> update_entry_builder(entry_builder, %{field: new_value})
      {:ok, %EntryBuilder{}}

      iex> update_entry_builder(entry_builder, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_entry_builder(%EntryBuilder{} = entry_builder, attrs) do
    entry_builder
    |> EntryBuilder.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a entry_builder.

  ## Examples

      iex> delete_entry_builder(entry_builder)
      {:ok, %EntryBuilder{}}

      iex> delete_entry_builder(entry_builder)
      {:error, %Ecto.Changeset{}}

  """
  def delete_entry_builder(%EntryBuilder{} = entry_builder) do
    Repo.delete(entry_builder)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entry_builder changes.

  ## Examples

      iex> change_entry_builder(entry_builder)
      %Ecto.Changeset{data: %EntryBuilder{}}
  """
  def change_entry_builder(%EntryBuilder{} = entry_builder, attrs \\ %{}) do
    EntryBuilder.changeset(entry_builder, attrs)
  end

  @doc """
  Verifies that the account and transaction is balanced and uses the same currency.
  Debit = Credit

  ## Examples

      iex> verify_and_balance_transactions(transactions)
      {:ok, [%Account{}, ...]}

      iex> verify_and_balance_transactions(invalid_transactions)
      {:error, error_message}
  """
  def verify_and_balance_transactions(transactions) do
    transactions
    |> BuildValidator.validate_transactions_balance()
    |> BuildValidator.validate_currencies_match()
    |> BuildValidator.validate_accounts_balance()
  end

  defp after_create_verify_and_balance_transactions(%{transactions: {_, transactions}} = results) do
    case verify_and_balance_transactions(transactions) do
      {:ok, _} -> {:ok, results}
      {:error, message} -> {:error, message, results}
    end
  end

  defp insert_all_transactions(transactions, entry) do
    changesets =
      Enum.map(transactions, fn %Ecto.Changeset{changes: changes} ->
        Map.merge(
          changes,
          %{
            entry_id: entry.id,
            inserted_at: entry.inserted_at,
            updated_at: entry.inserted_at
          }
        )
      end)

    Multi.new()
    |> Multi.insert_all(:transactions, Transaction, changesets, returning: true)
  end

  defp journal_entry_multi(entry, transactions) do
    Multi.new()
    |> Multi.insert(:entry, entry)
    |> Multi.merge(fn %{entry: entry} -> insert_all_transactions(transactions, entry) end)
    |> Repo.transaction()
    |> async_update_all_balances()
  end

  defp async_update_all_balances({:ok, %{transactions: {_, transactions}}} = result) do
    Enum.group_by(transactions, & &1.account_id)
    |> Task.async_stream(&async_update_balance(&1))
    |> Stream.run()

    result
  end

  defp async_update_all_balances(result), do: result

  defp async_update_balance({account_id, transactions}) do
    with %Balance{kind: kind, money: %{amount: amount, currency: currency}} = balance <-
           Accounts.get_balance!(%{account_id: account_id}),
         total <- async_sum_transactions_by_type(transactions, kind),
         money <- Money.new(amount + total, currency) do
      Accounts.update_balance(balance, money)
    end
  end

  defp async_sum_transactions_by_type(transactions, kind) do
    credits =
      Task.async(fn ->
        Enum.reduce(transactions, 0, fn transaction, acc ->
          case transaction.kind do
            "credit" -> acc + transaction.money.amount
            _ -> 0
          end
        end)
      end)

    debits =
      Task.async(fn ->
        Enum.reduce(transactions, 0, fn transaction, acc ->
          case transaction.kind do
            "debit" -> acc + transaction.money.amount
            _ -> 0
          end
        end)
      end)

    sum_credits_debits(Task.await(credits), Task.await(debits), kind)
  end

  defp sum_credits_debits(nil, debits, "credit"), do: -debits

  defp sum_credits_debits(credits, nil, "credit"), do: credits

  defp sum_credits_debits(credits, debits, "credit"), do: credits - debits

  defp sum_credits_debits(nil, debits, "debit"), do: debits

  defp sum_credits_debits(credits, nil, "debit"), do: -credits

  defp sum_credits_debits(credits, debits, "debit"), do: debits - credits

  defp return_invalid_changeset(%Ecto.Changeset{valid?: false} = entry, transactions) do
    bad_transactions = Enum.filter(transactions, fn changeset -> changeset.valid? != true end)

    {:error, %{entry: entry, transactions: bad_transactions}}
  end

  defp return_invalid_changeset(_entry, transactions) do
    bad_transactions = Enum.filter(transactions, fn changeset -> changeset.valid? != true end)

    {:error, %{transactions: bad_transactions}}
  end
end
