defmodule HubPayments.Payments.Charge do
  use Ecto.Schema
  import Ecto.Changeset

  alias HubPayments.Embeds.Owner

  schema "charges" do
    field :money, Money.Ecto.Map.Type
    field :process_date, :utc_datetime
    field :reference, :string
    field :request_date, :utc_datetime
    field :settle_date, :utc_datetime
    field :uuid, :string

    embeds_one :owner, Owner, on_replace: :update

    belongs_to :credit_card, HubPayments.Wallets.CreditCard
    belongs_to :provider, HubPayments.Providers.Provider

    timestamps()
  end

  @doc false
  def changeset(charge, attrs) do
    charge
    |> cast(attrs, [:credit_card_id, :money, :provider_id, :reference])
    |> cast_embed(:owner, with: &Owner.changeset/2)
    |> validate_required([:credit_card_id, :money, :provider_id])
    |> foreign_key_constraint(:credit_card_id)
    |> foreign_key_constraint(:provider_id)
    |> put_change(:request_date, now())
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def update_changeset(charge, attrs) do
    charge
    |> cast(attrs, [:credit_card_id, :money, :provider_id, :reference])
    |> cast_embed(:owner, with: &Owner.changeset/2)
  end

  defp now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end
end
