defmodule HubIdentityWeb.Authentication.ApiAuth do
  @moduledoc false
  import Plug.Conn

  alias HubIdentity.ClientServices
  alias HubIdentity.ClientServices.ApiKey

  def init(opts), do: opts

  def call(conn, type: api_type) do
    with [key_data] when is_binary(key_data) <- Plug.Conn.get_req_header(conn, "x-api-key"),
         %ApiKey{client_service: client_service, type: type} <-
           ClientServices.get_api_key_by_data(key_data),
         true <- api_type == type do
      conn
      |> fetch_session()
      |> put_session(:client_service, client_service)
      |> put_session(:api_permission, type)
    else
      _ ->
        conn
        |> send_resp(401, "not authorized")
        |> halt()
    end
  end
end
