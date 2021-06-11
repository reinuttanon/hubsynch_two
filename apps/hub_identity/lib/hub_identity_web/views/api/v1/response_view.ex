defmodule HubIdentityWeb.Api.V1.ResponseView do
  @moduledoc false
  use HubIdentityWeb, :view

  def render("facebook_delete_confirmation.json", %{url: url, data_deletion: data_deletion}) do
    %{
      url: url,
      confirmation_code: data_deletion.uid
    }
  end
end
