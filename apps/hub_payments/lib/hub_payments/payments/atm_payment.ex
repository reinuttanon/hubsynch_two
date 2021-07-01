defmodule HubPayments.Payments.AtmPayment do
  use Ecto.Schema
  import Ecto.Changeset

  alias HubPayments.Embeds.Owner

  schema "atm_payments" do
    field :amount, :integer, virtual: true
    field :currency, :string, virtual: true
    field :money, Money.Ecto.Map.Type
    field :payment_detail, :string
    field :payment_detail_kana, :string
    field :payment_limit_date, :integer
    field :process_date, :utc_datetime
    field :reference, :string
    field :request_date, :utc_datetime
    field :uuid, :string

    embeds_one :owner, Owner, on_replace: :update

    belongs_to :provider, HubPayments.Providers.Provider

    timestamps()
  end

  @doc false
  def changeset(atm_payment, attrs) do
    atm_payment
    |> cast(attrs, [
      :amount,
      :currency,
      :provider_id,
      :reference,
      :request_date,
      :process_date,
      :payment_detail,
      :payment_detail_kana,
      :payment_limit_date
    ])
    |> cast_embed(:owner, with: &Owner.changeset/2)
    |> make_money()
    |> validate_required([
      :owner,
      :money,
      :payment_detail,
      :payment_detail_kana,
      :payment_limit_date,
      :provider_id
    ])
    |> put_change(:request_date, now())
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def update_changeset(atm_payment, attrs) do
    atm_payment
    |> cast(attrs, [
      :credit_card_id,
      :money,
      :provider_id,
      :reference,
      :payment_detail,
      :payment_detail_kana,
      :payment_limit_date
    ])
    |> cast_embed(:owner, with: &Owner.changeset/2)
  end

  defp make_money(%Ecto.Changeset{changes: %{amount: amount, currency: currency}} = changeset) do
    put_change(changeset, :money, Money.new(amount, currency))
  end

  defp make_money(changeset), do: changeset

  defp now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end
end
