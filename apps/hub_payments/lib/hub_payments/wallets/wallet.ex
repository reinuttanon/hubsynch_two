defmodule HubPayments.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :owner, :map
    field :prefered_credit_card_uuid, :string
    field :uuid, :string

    timestamps()
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:owner, :prefered_credit_card_uuid, :uuid])
    |> validate_required([:owner, :prefered_credit_card_uuid, :uuid])
  end
end
