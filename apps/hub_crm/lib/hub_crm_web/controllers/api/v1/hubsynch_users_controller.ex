defmodule HubCrmWeb.Api.V1.HubsynchUsersController do
  @moduledoc false
  use HubCrmWeb, :api_controller

  alias HubCrm.Hubsynch

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    with false <- Hubsynch.user_exists?(email),
         {:ok, %Hubsynch.User{} = user} <- Hubsynch.create_user(user_params) do
      render(conn, "show.json", %{user: user})
    end
  end

  def create(_conn, _), do: {:error, :bad_request}

  def show(conn, %{"user_id" => user_id}) do
    with %Hubsynch.User{} = user <- Hubsynch.get_user(user_id),
         %Hubsynch.User{} = preloaded <- Hubsynch.preload_addresses(user) do
      render(conn, "show.json", %{user: preloaded})
    end
  end

  def show(conn, %{"email" => email}) do
    with %Hubsynch.User{} = user <- Hubsynch.get_user_by_email(email),
         %Hubsynch.User{} = preloaded <- Hubsynch.preload_addresses(user) do
      render(conn, "show.json", %{user: preloaded})
    end
  end

  def show(_conn, _), do: {:error, :bad_request}

  def update(conn, %{"user_id" => user_id, "user" => user_params}) do
    with {:ok, updated_user} <- update_user(user_id, user_params) do
      render(conn, "show.json", %{user: updated_user})
    end
  end

  def delete(conn, %{"user_id" => user_id}) do
    with %Hubsynch.User{} = user <- Hubsynch.get_user(user_id),
         {:ok, %Hubsynch.User{}} <- Hubsynch.delete_user(user) do
      conn
      |> send_resp(202, "successful operation")
      |> halt()
    end
  end

  defp update_user(user_id, params) do
    with %Hubsynch.User{} = user <- Hubsynch.get_user(user_id),
         {:ok, %Hubsynch.User{} = updated_user} <- Hubsynch.update_user(user, params),
         %Hubsynch.User{} = preloaded <- Hubsynch.preload_addresses(updated_user) do
      {:ok, preloaded}
    end
  end
end
