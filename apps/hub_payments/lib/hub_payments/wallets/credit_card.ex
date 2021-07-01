defmodule HubPayments.Wallets.CreditCard do
  use Ecto.Schema
  import Ecto.Changeset

  @months ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]

  schema "credit_cards" do
    field :brand, :string
    field :cvv, :string, virtual: true, redact: true
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
      :cvv,
      :brand,
      :cvv,
      :exp_month,
      :exp_year,
      :fingerprint,
      :last_four,
      :vault_uuid,
      :wallet_id
    ])
    |> validate_required([:brand, :exp_month, :exp_year, :fingerprint, :last_four])
    |> validate_length(:exp_year, is: 2)
    |> validate_inclusion(:exp_month, @months)
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def update_changeset(credit_card, attrs) do
    credit_card
    |> cast(attrs, [
      :exp_month,
      :exp_year,
      :vault_uuid
    ])
    |> validate_length(:exp_year, is: 2)
    |> validate_inclusion(:exp_month, @months)
    |> validate_required([:exp_month, :exp_year])
  end
end
