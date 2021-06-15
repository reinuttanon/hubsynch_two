defmodule HubPayments.Wallets.CreditCard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credit_cards" do
    field :brand, :string
    field :exp_month, :string
    field :exp_year, :string
    field :fingerprint, :string
    field :last_four, :string
    field :uuid, :string
    field :wallet_id, :id

    timestamps()
  end

  @doc false
  def changeset(credit_card, attrs) do
    credit_card
    |> cast(attrs, [:brand, :exp_month, :exp_year, :fingerprint, :last_four])
    |> validate_required([:brand, :exp_month, :exp_year, :fingerprint, :last_four])
    |> put_change(:uuid, Ecto.UUID.generate())
  end
end
