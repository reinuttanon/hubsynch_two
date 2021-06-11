defmodule HubPayments.Providers.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :data, :map
    field :owner, :map
    field :request, :string
    field :response, :string
    field :type, :string
    field :provider_id, :id

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:type, :owner, :request, :response, :data])
    |> validate_required([:type, :owner, :request, :response, :data])
  end
end
