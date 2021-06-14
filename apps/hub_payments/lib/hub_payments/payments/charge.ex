defmodule HubPayments.Payments.Charge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "charges" do
    field :money, Money.Ecto.Map.Type
    field :owner, :map
    field :process_date, :utc_datetime
    field :reference, :string
    field :request_date, :utc_datetime
    field :settle_date, :utc_datetime
    field :uuid, :string

    belongs_to :credit_card, HubPayments.Wallets.CreditCard
    belongs_to :provider, HubPayments.Providers.Provider

    timestamps()
  end

  @doc false
  def changeset(charge, attrs) do
    charge
    |> cast(attrs, [:credit_card_id, :provider_id, :reference, :money, :owner])
    |> validate_required([:credit_card_id, :provider_id, :money])
    |> foreign_key_constraint(:credit_card_id)
    |> foreign_key_constraint(:provider_id)
    |> put_change(:request_date, now())
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  defp now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end
end
