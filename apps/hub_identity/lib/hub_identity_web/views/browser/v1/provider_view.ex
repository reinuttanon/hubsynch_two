defmodule HubIdentityWeb.Browser.V1.ProviderView do
  @moduledoc false
  use HubIdentityWeb, :view

  # def provider_link_helper(provider) do
  #   link(provider.name, to: provider.request_url, class: "nav-link")
  # end

  def provider_link_helper(provider) do
    "/images/#{provider.name}.png"
    |> img_tag(
      alt: "#{provider.name} authentication link",
      width: "380"
    )
    |> link(to: provider.request_url, class: "nav-link")
  end
end
