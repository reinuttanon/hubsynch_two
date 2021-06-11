defmodule HubCrmWeb.Api.V1.CallbackController do
  use HubCrmWeb, :api_controller

  alias HubCrm.Hubsynch

  def show(conn, %{"email" => email}) do
    user = Hubsynch.get_user_by_email(email)
    render(conn, "show.json", %{user: user})
  end
end
