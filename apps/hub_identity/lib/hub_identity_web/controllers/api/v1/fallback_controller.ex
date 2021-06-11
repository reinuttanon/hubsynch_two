defmodule HubIdentityWeb.Api.V1.FallbackController do
  @moduledoc false
  use Phoenix.Controller, namespace: HubIdentityWeb

  import Plug.Conn

  def call(conn, {:error, _resource, %Ecto.Changeset{} = changeset, _}) do
    conn
    |> put_status(400)
    |> put_view(HubIdentityWeb.Api.V1.FallbackView)
    |> render("error.json", %{errors: changeset_errors(changeset)})
  end

  def call(conn, {:error, :authorization_required}) do
    conn
    |> put_status(400)
    |> put_view(HubIdentityWeb.Api.V1.FallbackView)
    |> render("error.json", %{
      error: "must have a valid reference and verification code to perform this action"
    })
  end

  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(400)
    |> put_view(HubIdentityWeb.Api.V1.FallbackView)
    |> render("error.json", %{error: message})
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(400)
    |> put_view(HubIdentityWeb.Api.V1.FallbackView)
    |> render("error.json", %{errors: changeset_errors(changeset)})
  end

  def call(conn, {:user_error, :user_not_found}) do
    conn
    |> put_status(400)
    |> put_view(HubIdentityWeb.Api.V1.FallbackView)
    |> render("error.json", %{error: "User not found"})
  end

  def call(conn, {:user_error, message}) do
    conn
    |> put_status(400)
    |> put_view(HubIdentityWeb.Api.V1.FallbackView)
    |> render("error.json", %{error: message})
  end

  def call(conn, _message) do
    conn
    |> send_resp(400, "bad request")
    |> halt()
  end

  defp changeset_errors(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", strigify(value))
      end)
    end)
  end

  defp changeset_errors(message), do: %{detail: message}

  defp strigify([:address]), do: ""

  defp strigify(value), do: to_string(value)
end
