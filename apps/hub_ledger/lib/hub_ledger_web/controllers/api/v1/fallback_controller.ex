defmodule HubLedgerWeb.Api.V1.FallbackController do
  @moduledoc false
  use Phoenix.Controller, namespace: HubLedgerWeb

  import Plug.Conn

  def call(conn, {:error, %{entry: entry, transactions: transactions}}) do
    transactions_errors = Enum.map(transactions, fn changeset -> changeset_errors(changeset) end)

    conn
    |> put_status(400)
    |> put_view(HubLedgerWeb.Api.V1.FallbackView)
    |> render("error.json", %{
      error: %{entry: changeset_errors(entry), transactions: transactions_errors}
    })
  end

  def call(conn, {:error, %{transactions: transactions}}) do
    transactions_errors = Enum.map(transactions, fn changeset -> changeset_errors(changeset) end)

    conn
    |> put_status(400)
    |> put_view(HubLedgerWeb.Api.V1.FallbackView)
    |> render("error.json", %{error: %{transactions: transactions_errors}})
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(400)
    |> put_view(HubLedgerWeb.Api.V1.FallbackView)
    |> render("error.json", %{error: changeset_errors(changeset)})
  end

  def call(conn, {:error, message}) do
    conn
    |> put_status(400)
    |> put_view(HubLedgerWeb.Api.V1.FallbackView)
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
