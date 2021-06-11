defmodule HubIdentity.ClientServices.Webhooks do
  @moduledoc false
  require Logger

  alias HubIdentity.ClientServices.ClientService

  @http Application.get_env(:hub_identity, :http)

  def get_user(%ClientService{webhook_auth_key: ""}, _email),
    do: {:ok, %{owner_uid: "", owner_type: ""}}

  def get_user(%ClientService{webhook_auth_type: ""}, _email),
    do: {:ok, %{owner_uid: "", owner_type: ""}}

  def get_user(%ClientService{webhook_url: ""}, _email),
    do: {:ok, %{owner_uid: "", owner_type: ""}}

  def get_user(_client_service, ""),
    do: {:ok, %{owner_uid: "", owner_type: ""}}

  def get_user(
        %ClientService{
          uid: uid,
          webhook_auth_key: auth_key,
          webhook_auth_type: auth_type,
          webhook_url: url
        },
        email
      )
      when is_binary(auth_key) and is_binary(auth_type) and is_binary(url) and is_binary(email) do
    @http.get("#{url}?email=#{email}", headers(auth_type, auth_key))
    |> parse_response(uid)
  end

  def get_user(_client_service, _email), do: {:ok, %{owner_uid: "", owner_type: ""}}

  defp headers("x-api-key", auth_key) do
    [{"x-api-key", auth_key}]
  end

  defp headers(standard, auth_key) do
    [{"authorization", "#{standard} #{auth_key}"}]
  end

  defp parse_body({:ok, %{"owner_uid" => owner_uid, "owner_type" => owner_type}}, _uid)
       when is_binary(owner_uid) and is_binary(owner_type),
       do: {:ok, %{owner_uid: owner_uid, owner_type: owner_type}}

  defp parse_body({:ok, %{"owner_uid" => owner_uid, "owner_type" => owner_type}}, _uid)
       when is_integer(owner_uid) and is_binary(owner_type) do
    string_uid = Integer.to_string(owner_uid)
    {:ok, %{owner_uid: string_uid, owner_type: owner_type}}
  end

  defp parse_body({:ok, %{"owner_uid" => owner_uid, "owner_type" => owner_type}}, _uid)
       when is_binary(owner_uid) and is_integer(owner_type) do
    string_type = Integer.to_string(owner_type)
    {:ok, %{owner_uid: owner_uid, owner_type: string_type}}
  end

  defp parse_body({:ok, ""}, _uid), do: {:ok, %{owner_uid: "", owner_type: ""}}

  defp parse_body({:ok, data}, uid) do
    message = %{client_service: uid, malformed_body: data}
    Logger.error(message)
    {:error, message}
  end

  defp parse_body({:error, %Jason.DecodeError{data: data}}, uid) do
    message = %{client_service: uid, jason_error: data}
    Logger.error(message)
    {:error, message}
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, uid) do
    body
    |> Jason.decode()
    |> parse_body(uid)
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: code, body: body}}, uid) do
    message = %{client_service: uid, http_error: code, body: body}
    Logger.error(message)
    {:error, message}
  end

  defp parse_response({:error, %HTTPoison.Error{reason: reason}}, uid) do
    message = %{client_service: uid, http_error: reason}
    Logger.error(message)
    {:error, message}
  end
end
