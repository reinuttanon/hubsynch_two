defmodule HubPaymentsWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use HubPaymentsWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(400)
    |> put_view(HubPaymentsWeb.Api.V1.FallbackView)
    |> render("error.json", %{error: changeset_errors(changeset)})
  end

  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(400)
    |> put_view(HubPaymentsWeb.Api.V1.FallbackView)
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
