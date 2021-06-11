defmodule HubIdentityWeb.AdministratorSessionController do
  @moduledoc false

  use HubIdentityWeb, :controller

  alias HubIdentity.Administration
  alias HubIdentityWeb.Authentication.AdministratorAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"administrator" => administrator_params}) do
    %{"email" => address, "password" => password} = administrator_params

    if administrator = Administration.get_administrator_by_email_and_password(address, password) do
      AdministratorAuth.log_in_administrator(conn, administrator, administrator_params)
    else
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> AdministratorAuth.log_out_administrator()
  end
end
