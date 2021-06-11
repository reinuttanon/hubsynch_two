defmodule HubCrmWeb.Api.V2.UserController do
  use HubCrmWeb, :api_controller

  alias HubCrm.Identities
  alias HubCrm.Identities.User

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Identities.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"uuid" => uuid}) do
    user = Identities.get_user(%{uuid: uuid})
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"uuid" => uuid, "user" => user_params}) do
    user = Identities.get_user(%{uuid: uuid})

    with {:ok, %User{} = user} <- Identities.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    user = Identities.get_user(%{uuid: uuid})

    with {:ok, %User{}} <- Identities.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
