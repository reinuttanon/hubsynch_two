defmodule HubPayments.Wallets.CreditCard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credit_cards" do
    field :brand, :string
    field :exp_month, :string
    field :exp_year, :string
    field :fingerprint, :string
    field :last_four, :string
    field :vault_uuid, :string
    field :uuid, :string

    belongs_to :wallet, HubPayments.Wallets.Wallet

    timestamps()
  end

  @doc false
  def changeset(credit_card, attrs) do
    credit_card
    |> cast(attrs, [
      :brand,
      :exp_month,
      :exp_year,
      :fingerprint,
      :last_four,
      :vault_uuid,
      :wallet_id
    ])
    |> validate_required([:brand, :exp_month, :exp_year, :fingerprint, :last_four])
    |> validate_exp_month()
    |> validate_exp_year()
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def update_changeset(credit_card, attrs) do
    credit_card
    |> cast(attrs, [
      :brand,
      :exp_month,
      :exp_year,
      :fingerprint,
      :last_four,
      :vault_uuid,
      :wallet_id
    ])
    |> validate_exp_month()
    |> validate_exp_year()
    |> validate_required([:brand, :exp_month, :exp_year, :fingerprint, :last_four])
  end

  defp validate_exp_month(
         %Ecto.Changeset{valid?: true, changes: %{exp_month: exp_month}} = changeset
       ) do
    with {int_value, ""} <- Integer.parse(exp_month),
         true <- int_value <= 12 and int_value >= 1 do
      changeset
    else
      :error -> add_error(changeset, :exp_month, "Exp month must be a number")
      {_, _} -> add_error(changeset, :exp_month, "Exp month must be a whole number")
      false -> add_error(changeset, :exp_month, "Exp month must be a between 01 and 12")
    end
  end

  defp validate_exp_month(changeset), do: changeset

  defp validate_exp_year(
         %Ecto.Changeset{valid?: true, changes: %{exp_year: exp_year}} = changeset
       ) do
    current_year =
      String.slice("#{DateTime.utc_now().year}", -2..-1)
      |> String.to_integer()

    with {int_value, ""} <- Integer.parse(exp_year),
         true <- int_value <= 99 and int_value >= current_year do
      changeset
    else
      :error ->
        add_error(changeset, :exp_month, "Exp year must be a number")

      {_, _} ->
        add_error(changeset, :exp_month, "Exp year must be a whole number")

      false ->
        add_error(
          changeset,
          :exp_month,
          "Exp year must be greater than or equals to the current year"
        )
    end
  end

  defp validate_exp_year(changeset), do: changeset
end
