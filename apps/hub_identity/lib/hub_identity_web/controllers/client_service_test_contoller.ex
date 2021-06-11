defmodule HubIdentityWeb.ClientServiceTestController do
  @moduledoc false

  use HubIdentityWeb, :controller

  alias HubIdentity.{ClientServices, Encryption}
  alias HubIdentity.ClientServices.ClientService

  def redirect_test(conn, %{"id" => id}) do
    client_service = ClientServices.get_client_service!(id)
    render(conn, "redirect.html", client_service: client_service)
  end

  def generate_redirect(conn, %{"id" => id}) do
    %ClientService{redirect_url: redirect_url} = ClientServices.get_client_service!(id)
    cookie_id = Encryption.Helpers.generate_data()

    redirect(conn, external: "#{redirect_url}?user_token=#{cookie_id}")
  end
end
