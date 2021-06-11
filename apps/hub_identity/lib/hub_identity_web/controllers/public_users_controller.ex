defmodule HubIdentityWeb.PublicUsersController do
  @moduledoc false
  alias HubIdentity.Metrics
  alias HubIdentity.Metrics.UserActivity

  use HubIdentityWeb, :controller

  def complete(conn, _params) do
    render(conn, "complete.html")
  end

  def data_delete_confirmation(conn, %{"uid" => uid}) do
    with %UserActivity{} = user_activity <-
           Metrics.get_user_activity(%{uid: uid, type: "Identity.delete"}) do
      render(conn, "delete_confirmation.html", %{user_activity: user_activity})
    end
  end
end
