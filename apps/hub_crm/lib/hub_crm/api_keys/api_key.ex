defmodule HubCrm.ApiKeys.ApiKey do
  use Ecto.Schema

  schema "api_keys" do
    field :client_service_id, :integer
    field :data, :string
    field :deleted_at, :utc_datetime
    field :type, :string
    field :uid, :string

    timestamps()
  end
end
