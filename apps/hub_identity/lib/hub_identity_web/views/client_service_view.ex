defmodule HubIdentityWeb.ClientServiceView do
  @moduledoc false
  use HubIdentityWeb, :view

  def active?(nil), do: true

  def active?(_), do: false

  def webhook_auth_types, do: HubIdentity.ClientServices.ClientService.webhook_auth_types()
end
