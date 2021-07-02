defmodule HubIdentity.ClientServices.ClientService do
  use Ecto.Schema
  use HubIdentity.SoftDelete
  use HubIdentity.Uid

  import Ecto.Changeset

  alias HubIdentity.Administration.Administrator
  alias HubIdentity.ClientServices.ApiKey

  @auth_types ["basic", "bearer", "x-api-key"]

  schema "client_services" do
    field :deleted_at, :utc_datetime
    field :description, :string
    field :name, :string
    field :redirect_url, :string
    field :refresh_token, :boolean, default: false
    field :uid, :string
    field :url, :string
    field :logo, :string
    field :email_confirmation_redirect_url, :string
    field :pass_change_redirect_url, :string
    # These are older implementation, that may have future use cases.
    field :webhook_auth_key, :string
    field :webhook_auth_type, :string
    field :webhook_url, :string

    has_many :api_keys, ApiKey

    many_to_many :administrators, Administrator,
      join_through: "administrators_client_services",
      on_replace: :delete

    timestamps()
  end

  @doc false
  def new_changeset(client_service, attrs, administrator) do
    client_service
    |> cast(attrs, [
      :description,
      :name,
      :redirect_url,
      :refresh_token,
      :url,
      :logo,
      :email_confirmation_redirect_url,
      :pass_change_redirect_url
    ])
    |> validate_required([
      :description,
      :name,
      :email_confirmation_redirect_url,
      :redirect_url,
      :url
    ])
    |> validate_inclusion(:webhook_auth_type, @auth_types)
    |> put_assoc(:administrators, [administrator])
    |> put_uid()
  end

  @doc false
  def update_changeset(client_service, attrs) do
    client_service
    |> cast(attrs, [
      :description,
      :name,
      :redirect_url,
      :refresh_token,
      :url,
      :logo,
      :email_confirmation_redirect_url,
      :pass_change_redirect_url
    ])
    |> validate_required([:description, :name, :redirect_url, :url])
    |> validate_inclusion(:webhook_auth_type, @auth_types)
  end

  @doc false
  def webhook_auth_types, do: @auth_types
end
