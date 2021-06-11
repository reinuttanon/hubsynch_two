defmodule HubCrm.Hubsynch.UseApp do
  @moduledoc false
  use Ecto.Schema
  # import Ecto.Changeset

  @primary_key {:use_app_id, :id, autogenerate: true}

  schema "use_apps" do
    field :company_app_id, :integer
    field :company_id, :integer
    field :user_id, :integer
    field :guest_id, :integer
    field :developer_purchase_user_id, :integer
    field :delete_flag, :string, default: "false"

    timestamps(inserted_at: :create_timestamp, updated_at: :update_timestamp)
  end
end
