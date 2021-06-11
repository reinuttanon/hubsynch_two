defmodule HubIdentity.Providers.Oauth2Provider do
  alias HubIdentity.Providers.ProviderConfig

  use Memento.Table,
    attributes: [:id, :name, :logo_url, :token_url, :request_url],
    index: [:name],
    type: :set

  def create_changeset(%ProviderConfig{id: id, name: name} = provider_config) do
    %__MODULE__{
      id: id,
      name: name,
      logo_url: build_logo_url(name),
      token_url: ProviderConfig.build_token_url(provider_config),
      request_url: ProviderConfig.build_request_url(provider_config)
    }
  end

  def update_request_url(%__MODULE__{request_url: request_url} = provider, state)
      when is_binary(state) do
    %{provider | request_url: "#{request_url}&state=#{state}"}
  end

  def update_token_url(%__MODULE__{token_url: token_url} = provider, code)
      when is_binary(code) do
    %{provider | token_url: "#{token_url}&code=#{code}"}
  end

  def build_logo_url(name) do
    "#{HubIdentityWeb.Endpoint.url()}/images/#{name}.png"
  end
end
