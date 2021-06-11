defmodule HubCrmWeb.Plugs.ApiAuth do
  import Plug.Conn

  alias HubIdentity.ClientServices
  alias HubIdentity.ClientServices.ApiKey

  def init(opts), do: opts

  def call(conn, _opts) do
    with [key_data] when is_binary(key_data) <- Plug.Conn.get_req_header(conn, "x-api-key"),
         %ApiKey{type: type} = api_key <- ClientServices.get_api_key_by_data(key_data),
         true <- type == "private" do
      conn
      |> fetch_session()
      |> put_session(:api_key, api_key)
    else
      _ ->
        conn
        |> send_resp(401, "not authorized")
        |> halt()
    end
  end
end
