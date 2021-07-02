defmodule HubPayments.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  alias HubPayments.Repo

  alias HubPayments.Payments.Charge
  alias HubPayments.Wallets.CreditCard
  alias HubPayments.Providers.Provider

  @doc """
  Returns the list of charges.

  ## Examples

      iex> list_charges()
      [%Charge{}, ...]

  """
  def list_charges do
    Repo.all(Charge)
  end

  @doc """
  Gets a single charge.

  Raises `Ecto.NoResultsError` if the Charge does not exist.

  ## Examples

      iex> get_charge!(123)
      %Charge{}

      iex> get_charge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_charge!(id), do: Repo.get!(Charge, id)

  def get_charge(%{uuid: uuid}) do
    query =
      from c in Charge,
        where: c.uuid == ^uuid

    Repo.one(query)
  end

  @doc """
  Creates a charge.

  ## Examples

      iex> create_charge(%{field: value})
      {:ok, %Charge{}}

      iex> create_charge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_charge(charge_params, %Provider{id: provider_id}, %CreditCard{id: credit_card_id}) do
    charge_params
    |> Map.put("provider_id", provider_id)
    |> Map.put("credit_card_id", credit_card_id)
    |> create_charge()
  end

  def create_charge(attrs \\ %{}) do
    %Charge{}
    |> Charge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a charge.

  ## Examples

      iex> update_charge(charge, %{field: new_value})
      {:ok, %Charge{}}

      iex> update_charge(charge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_charge(%Charge{} = charge, attrs) do
    charge
    |> Charge.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a charge.

  ## Examples

      iex> delete_charge(charge)
      {:ok, %Charge{}}

      iex> delete_charge(charge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_charge(%Charge{} = charge) do
    Repo.delete(charge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking charge changes.

  ## Examples

      iex> change_charge(charge)
      %Ecto.Changeset{data: %Charge{}}

  """
  def change_charge(%Charge{} = charge, attrs \\ %{}) do
    Charge.changeset(charge, attrs)
  end

  alias HubPayments.Payments.Point

  @doc """
  Returns the list of points.

  ## Examples

      iex> list_points()
      [%Point{}, ...]

  """
  def list_points do
    Repo.all(Point)
  end

  @doc """
  Gets a single point.

  Raises `Ecto.NoResultsError` if the Point does not exist.

  ## Examples

      iex> get_point!(123)
      %Point{}

      iex> get_point!(456)
      ** (Ecto.NoResultsError)

  """
  def get_point!(id), do: Repo.get!(Point, id)

  @doc """
  Creates a point.

  ## Examples

      iex> create_point(%{field: value})
      {:ok, %Point{}}

      iex> create_point(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_point(attrs \\ %{}) do
    %Point{}
    |> Point.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a point.

  ## Examples

      iex> update_point(point, %{field: new_value})
      {:ok, %Point{}}

      iex> update_point(point, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_point(%Point{} = point, attrs) do
    point
    |> Point.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a point.

  ## Examples

      iex> delete_point(point)
      {:ok, %Point{}}

      iex> delete_point(point)
      {:error, %Ecto.Changeset{}}

  """
  def delete_point(%Point{} = point) do
    Repo.delete(point)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking point changes.

  ## Examples

      iex> change_point(point)
      %Ecto.Changeset{data: %Point{}}

  """
  def change_point(%Point{} = point, attrs \\ %{}) do
    Point.changeset(point, attrs)
  end

  alias HubPayments.Payments.AtmPayment

  @doc """
  Returns the list of atm_payments.

  ## Examples

      iex> list_atm_payments()
      [%AtmPayment{}, ...]

  """

  def list_atm_payments do
    Repo.all(AtmPayment)
  end

  @doc """
  Gets a single AtmPayment.

  Raises `Ecto.NoResultsError` if the AtmPayment does not exist.

  ## Examples

      iex> get_atm_payment!(123)
      %AtmPayment{}

      iex> get_atm_payment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_atm_payment!(id), do: Repo.get!(AtmPayment, id)

  @doc """
  Creates a atm_payment.

  ## Examples

      iex> create_atm_payment(%{field: value})
      {:ok, %AtmPayment{}}

      iex> create_atm_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_atm_payment(atm_payment_params, %Provider{id: provider_id}) do
    atm_payment_params
    |> Map.put("provider_id", provider_id)
    |> create_atm_payment()
  end

  def create_atm_payment(attrs \\ %{}) do
    %AtmPayment{}
    |> AtmPayment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a atm_payment.

  ## Examples

      iex> update_atm_payment(atm_payment, %{field: new_value})
      {:ok, %AtmPayment{}}

      iex> update_atm_payment(atm_payment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_atm_payment(%AtmPayment{} = atm_payment, attrs) do
    atm_payment
    |> AtmPayment.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a atm_payment.

  ## Examples

      iex> delete_atm_payment(atm_payment)
      {:ok, %AtmPayment{}}

      iex> delete_atm_payment(atm_payment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_atm_payment(%AtmPayment{} = atm_payment) do
    Repo.delete(atm_payment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking atm_payment changes.

  ## Examples

      iex> change_atm_payment(atm_payment)
      %Ecto.Changeset{data: %AtmPayment{}}

  """
  def change_atm_payment(%AtmPayment{} = atm_payment, attrs \\ %{}) do
    AtmPayment.changeset(atm_payment, attrs)
  end
end
