defmodule HubPayments.ClientServices.PaymentConfig do
  use Ecto.Schema
  use HubIdentity.UUID
  use HubIdentity.SoftDelete
  import Ecto.Changeset

  @payment_methods ["credit_card", "points"]

  schema "payment_configs" do
    field :client_service_uuid, :string
    field :deleted_at, :utc_datetime
    field :payment_methods, {:array, :string}
    field :statement_name, :string
    field :uuid, :string

    belongs_to :provider, HubPayments.Providers.Provider

    timestamps()
  end

  @doc false
  def changeset(payment_config, attrs) do
    payment_config
    |> cast(attrs, [:client_service_uuid, :payment_methods, :statement_name])
    |> validate_required([:client_service_uuid, :payment_methods])
    |> validate_length(:payment_methods, min: 1)
    |> validate_subset(:payment_methods, @payment_methods)
    |> put_uuid()
  end

  def update_changeset(payment_config, attrs) do
    payment_config
    |> cast(attrs, [:client_service_uuid, :payment_methods, :statement_name])
    |> validate_required([:client_service_uuid, :payment_methods])
    |> validate_length(:payment_methods, min: 1)
    |> validate_subset(:payment_methods, @payment_methods)
  end
end
