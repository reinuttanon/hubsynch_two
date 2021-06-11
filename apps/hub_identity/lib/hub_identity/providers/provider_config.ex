defmodule HubIdentity.Providers.ProviderConfig do
  use Ecto.Schema
  use HubIdentity.Uuid

  import Ecto.Changeset

  @redirect_host Application.get_env(:hub_identity, :redirect_host)
  @redirect_path "/api/v1/providers/oauth/response"

  schema "provider_configs" do
    field :active, :boolean, default: false
    field :access_token_url, :string
    field :auth_url, :string
    field :client_id, :string
    field :client_secret, :string
    field :deleted_at, :utc_datetime
    field :name, :string
    field :scopes, :string
    field :uid, :string

    timestamps()
  end

  @doc false
  def changeset(provider_config, attrs) do
    provider_config
    |> cast(attrs, [
      :access_token_url,
      :active,
      :auth_url,
      :client_id,
      :client_secret,
      :name,
      :scopes
    ])
    |> validate_required([:name, :client_id, :client_secret, :auth_url])
    |> normalize_name()
    |> put_uid()
  end

  def build_request_url(%__MODULE__{scopes: scopes} = provider_config) do
    provider_config
    |> request_url()
    |> add_scopes(scopes)
  end

  def build_token_url(%__MODULE__{
        access_token_url: access_token_url,
        client_id: client_id,
        client_secret: client_secret,
        name: name
      }) do
    "#{access_token_url}?client_id=#{client_id}&client_secret=#{client_secret}&grant_type=authorization_code&redirect_uri=#{
      redirect_uri(name)
    }"
  end

  defp request_url(%__MODULE__{auth_url: auth_url, client_id: client_id, name: name}) do
    "#{auth_url}?client_id=#{client_id}&response_type=code&redirect_uri=#{redirect_uri(name)}"
  end

  defp add_scopes(url, nil), do: url

  defp add_scopes(url, ""), do: url

  defp add_scopes(url, []), do: url

  defp add_scopes(url, scope_list) do
    "#{url}&scope=#{scope_list}"
  end

  defp normalize_name(%Ecto.Changeset{valid?: true} = changeset) do
    with {_, name} <- Ecto.Changeset.fetch_field(changeset, :name),
         normalized when is_binary(normalized) <- downcase_snake(name) do
      Ecto.Changeset.put_change(changeset, :name, normalized)
    end
  end

  defp normalize_name(changeset), do: changeset

  defp downcase_snake(string) when is_binary(string) do
    string
    |> String.downcase()
    |> String.replace(" ", "_")
  end

  defp redirect_uri(name) do
    "#{@redirect_host}#{@redirect_path}/#{name}"
  end
end
