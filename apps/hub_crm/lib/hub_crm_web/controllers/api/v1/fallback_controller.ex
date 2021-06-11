defmodule HubCrmWeb.Api.V1.FallbackController do
  use Phoenix.Controller, namespace: HubCrmWeb

  import Plug.Conn

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(400)
    |> put_view(HubCrmWeb.Api.V1.FallbackView)
    |> render("error.json", %{errors: changeset_errors(changeset)})
  end

  def call(conn, _) do
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

  defp strigify([:email]), do: ""

  defp strigify(value), do: to_string(value)
end
