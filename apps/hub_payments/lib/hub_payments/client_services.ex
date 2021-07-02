defmodule HubPayments.ClientServices do
  @moduledoc """
  The ClientServices context.
  """

  import Ecto.Query, warn: false
  alias HubPayments.Repo

  alias HubPayments.ClientServices.PaymentConfig

  @doc """
  Returns the list of payment_configs.

  ## Examples

      iex> list_payment_configs()
      [%PaymentConfig{}, ...]

  """
  def list_payment_configs do
    Repo.all(PaymentConfig)
  end

  @doc """
  Gets a single payment_config.

  Raises `Ecto.NoResultsError` if the Payment config does not exist.

  ## Examples

      iex> get_payment_config!(123)
      %PaymentConfig{}

      iex> get_payment_config!(456)
      ** (Ecto.NoResultsError)

  """
  def get_payment_config!(id), do: Repo.get!(PaymentConfig, id)

  @doc """
  Creates a payment_config.

  ## Examples

      iex> create_payment_config(%{field: value})
      {:ok, %PaymentConfig{}}

      iex> create_payment_config(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment_config(attrs \\ %{}) do
    %PaymentConfig{}
    |> PaymentConfig.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a payment_config.

  ## Examples

      iex> update_payment_config(payment_config, %{field: new_value})
      {:ok, %PaymentConfig{}}

      iex> update_payment_config(payment_config, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment_config(%PaymentConfig{} = payment_config, attrs) do
    payment_config
    |> PaymentConfig.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a payment_config.

  ## Examples

      iex> delete_payment_config(payment_config)
      {:ok, %PaymentConfig{}}

      iex> delete_payment_config(payment_config)
      {:error, %Ecto.Changeset{}}

  """
  def delete_payment_config(%PaymentConfig{} = payment_config) do
    payment_config
    |> PaymentConfig.delete_changeset()
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment_config changes.

  ## Examples

      iex> change_payment_config(payment_config)
      %Ecto.Changeset{data: %PaymentConfig{}}

  """
  def change_payment_config(%PaymentConfig{} = payment_config, attrs \\ %{}) do
    PaymentConfig.changeset(payment_config, attrs)
  end
end
