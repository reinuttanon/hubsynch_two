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
    |> validate_length(:exp_month, is: 2)
    |> validate_length(:exp_year, is: 2)
    |> validate_inclusion(:exp_month, Enum.map(1..12, fn x -> String.slice("0#{x}", -2..-1) end))
    |> validate_inclusion(:exp_year, Enum.map(00..99, fn x -> String.slice("0#{x}", -2..-1) end))
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
    |> validate_inclusion(:exp_month, Enum.map(1..12, fn x -> String.slice("0#{x}", -2..-1) end))
    |> validate_inclusion(:exp_year, Enum.map(0..99, fn x -> String.slice("0#{x}", -2..-1) end))
    |> validate_required([:brand, :exp_month, :exp_year, :fingerprint, :last_four])
  end
end
