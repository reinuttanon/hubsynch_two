defmodule HubLedger.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias HubLedger.Repo

  alias HubLedger.Accounts.{Account, Balance}
  alias HubLedger.Ledgers

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id) |> Repo.preload([:balance])

  def get_account(%{uuid: uuid}) do
    query =
      from a in Account,
        where: a.uuid == ^uuid

    Repo.one(query)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account_by_owner(%{"object" => object, "uid" => uid})
      %Account{}

      iex> get_account_by_owner(%{})
      ** (Ecto.NoResultsError)

  """
  def get_account_by_owner(%{"object" => object, "uid" => uid}) do
    query =
      from a in Account,
        where: fragment("owner->>'object' = ? AND owner->>'uid' = ?", ^object, ^uid)

    Repo.one(query)
  end

  @doc """
  Gets the accounts balance with account uuid.

  Raises {:error, "invalid Account"} if the Account does not exist.

  ## Examples

      iex> get_account_by_owner(%{uuid: uuid})
      %Money{amount: amount, currency: currency}

      iex> get_account_by_owner(%{uuid: uuid})
      {:error, "invalid Account"}

  """
  def get_account_balance(%{uuid: uuid}) do
    with %Account{currency: currency} = account <- get_account(%{uuid: uuid}),
         amount when amount != nil <- sum_transactions(account) do
      Money.new(amount, currency)
    else
      nil -> {:error, "invalid Account"}
    end
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:account, Account.create_changeset(%Account{}, attrs))
    |> Multi.insert(:balance, fn %{account: account} -> Balance.create_changeset(account) end)
    |> Repo.transaction()
  end

  @doc """
  Creates an empty account.

  ## Examples

      iex> new_account(%{field: value})
      %Account{}
  """
  def new_account do
    Account.create_changeset(%Account{}, %{})
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Creates a accounts update_changeset.

  ## Examples

      iex> change_account(account, %{field: new_value})
      %Ecto.Changeset{}
  """
  def change_account(%Account{} = account, attrs) do
    Account.update_changeset(account, attrs)
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns the list of balances.

  ## Examples

      iex> list_balances()
      [%Balance{}, ...]

  """
  def list_balances do
    Repo.all(Balance)
  end

  @doc """
  Updates a balance.

  ## Examples

      iex> update_balance(balance, %{field: new_value})
      {:ok, %Balance{}}

      iex> update_balance(balance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_balance(balance, new_money) do
    balance
    |> Balance.update_changeset(new_money)
    |> Repo.update()
  end

  @doc """
  Gets a single balance.

  Raises `Ecto.NoResultsError` if the Balance does not exist.

  ## Examples

      iex> get_balance!(123)
      %Balance{}

      iex> get_balance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_balance!(%{account_id: account_id}) do
    query =
      from b in Balance,
        where: b.account_id == ^account_id

    Repo.one(query)
  end

  def get_balance!(id), do: Repo.get!(Balance, id)

  defp sum_transactions(%Account{id: id, kind: kind}) do
    credits = Ledgers.sum_transactions(%{account_id: id, kind: "credit"})
    debits = Ledgers.sum_transactions(%{account_id: id, kind: "debit"})

    case kind do
      "credit" -> credits - debits
      "debit" -> debits - credits
    end
  end
end
