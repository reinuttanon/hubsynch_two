defmodule HubPayments.Wallets do
  @moduledoc """
  The Wallets context.
  """

  import Ecto.Query, warn: false
  alias HubPayments.Repo

  alias HubPayments.Wallets.Wallet

  @doc """
  Returns the list of wallets.

  ## Examples

      iex> list_wallets()
      [%Wallet{}, ...]

  """
  def list_wallets do
    Repo.all(Wallet)
  end

  @doc """
  Gets a single wallet.

  Raises `Ecto.NoResultsError` if the Wallet does not exist.

  ## Examples

      iex> get_wallet!(123)
      %Wallet{}

      iex> get_wallet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wallet!(id), do: Repo.get!(Wallet, id)

  @doc """
  Creates a wallet.

  ## Examples

      iex> create_wallet(%{field: value})
      {:ok, %Wallet{}}

      iex> create_wallet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wallet(attrs \\ %{}) do
    %Wallet{}
    |> Wallet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wallet.

  ## Examples

      iex> update_wallet(wallet, %{field: new_value})
      {:ok, %Wallet{}}

      iex> update_wallet(wallet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wallet(%Wallet{} = wallet, attrs) do
    wallet
    |> Wallet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a wallet.

  ## Examples

      iex> delete_wallet(wallet)
      {:ok, %Wallet{}}

      iex> delete_wallet(wallet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wallet(%Wallet{} = wallet) do
    Repo.delete(wallet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wallet changes.

  ## Examples

      iex> change_wallet(wallet)
      %Ecto.Changeset{data: %Wallet{}}

  """
  def change_wallet(%Wallet{} = wallet, attrs \\ %{}) do
    Wallet.changeset(wallet, attrs)
  end

  alias HubPayments.Wallets.CreditCard

  @doc """
  Returns the list of credit_cards.

  ## Examples

      iex> list_credit_cards()
      [%CreditCard{}, ...]

  """
  def list_credit_cards do
    Repo.all(CreditCard)
  end

  @doc """
  Gets a single credit_card.

  Raises `Ecto.NoResultsError` if the Credit card does not exist.

  ## Examples

      iex> get_credit_card!(123)
      %CreditCard{}

      iex> get_credit_card!(456)
      ** (Ecto.NoResultsError)

  """
  def get_credit_card!(id), do: Repo.get!(CreditCard, id)

  @doc """
  Creates a credit_card.

  ## Examples

      iex> create_credit_card(%{field: value})
      {:ok, %CreditCard{}}

      iex> create_credit_card(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_credit_card(attrs \\ %{}) do
    %CreditCard{}
    |> CreditCard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a credit_card.

  ## Examples

      iex> update_credit_card(credit_card, %{field: new_value})
      {:ok, %CreditCard{}}

      iex> update_credit_card(credit_card, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_credit_card(%CreditCard{} = credit_card, attrs) do
    credit_card
    |> CreditCard.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a credit_card.

  ## Examples

      iex> delete_credit_card(credit_card)
      {:ok, %CreditCard{}}

      iex> delete_credit_card(credit_card)
      {:error, %Ecto.Changeset{}}

  """
  def delete_credit_card(%CreditCard{} = credit_card) do
    Repo.delete(credit_card)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credit_card changes.

  ## Examples

      iex> change_credit_card(credit_card)
      %Ecto.Changeset{data: %CreditCard{}}

  """
  def change_credit_card(%CreditCard{} = credit_card, attrs \\ %{}) do
    CreditCard.changeset(credit_card, attrs)
  end
end
