defmodule HubPayments.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  alias HubPayments.Embeds.Owner

  schema "wallets" do
    field :prefered_credit_card_uuid, :string
    field :uuid, :string

    embeds_one :owner, Owner, on_replace: :update
    has_many :credit_cards, HubPayments.Wallets.CreditCard
    timestamps()
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:prefered_credit_card_uuid])
    |> cast_embed(:owner, with: &Owner.changeset/2)
    |> validate_required([:owner])
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def update_changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:prefered_credit_card_uuid])
    |> validate_required([:owner, :uuid])
  end
end
