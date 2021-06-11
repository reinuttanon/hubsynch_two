defmodule HubIdentityWeb.PublicUsersControllerTest do
  use HubIdentityWeb.ConnCase

  import HubIdentity.Factory

  test "GET /public_users/data_delete_confirmation", %{conn: conn} do
    user_activity = insert(:user_activity, owner_type: "Identity", type: "Identity.delete")

    response =
      get(conn, Routes.public_users_path(conn, :data_delete_confirmation, user_activity.uid))
      |> html_response(200)

    assert response =~ "Data Deletion Confirmation"
    assert response =~ "Your Data was deleted on"
    assert response =~ user_activity.uid
  end
end
