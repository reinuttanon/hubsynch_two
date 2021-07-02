defmodule HubIdentity.ClientServices.ApiKey do
  use Ecto.Schema
  use HubIdentity.SoftDelete
  use HubIdentity.Uid

  import Ecto.Changeset
  import HubIdentity.Encryption.Helpers, only: [generate_data: 1]

  schema "api_keys" do
    field :data, :string
    field :deleted_at, :utc_datetime
    field :type, :string
    field :uid, :string

    belongs_to :client_service, HubIdentity.ClientServices.ClientService

    timestamps()
  end

  @doc false
  def changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:client_service_id, :type])
    |> validate_required([:client_service_id, :type])
    |> validate_inclusion(:type, ["public", "private"])
    |> put_uid()
    |> put_data()
  end

  defp put_data(%Ecto.Changeset{valid?: true} = changeset) do
    data =
      case get_change(changeset, :type) do
        "public" -> generate_data("pub")
        "private" -> generate_data("prv")
      end

    put_change(changeset, :data, data)
  end

  defp put_data(changeset), do: changeset
end
