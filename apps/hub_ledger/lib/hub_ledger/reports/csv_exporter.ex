defmodule HubLedger.Reports.CsvExporter do
  alias HubLedger.Accounts.{Account, Balance}
  alias HubLedger.Ledgers.{Entry, Transaction}

  def generate([record | _] = data) do
    data
    |> Enum.map(&convert(&1))
    |> CSV.encode(headers: headers(record))
    |> Enum.to_list()
    |> to_string()
  end

  defp convert(%Account{
         currency: currency,
         type: type,
         name: name,
         uuid: uuid,
         owner: owner,
         balance: %Balance{money: money}
       }) do
    %{
      "uuid" => uuid,
      "name" => name,
      "currency" => currency,
      "type" => type,
      "owner_object" => owner.object,
      "owner_uid" => owner.uid,
      "balance" => Money.to_string(money)
    }
  end

  defp convert(%Entry{description: description, uuid: uuid, owner: owner}) do
    %{
      "uuid" => uuid,
      "description" => description,
      "owner_object" => owner.object,
      "owner_uid" => owner.uid
    }
  end

  defp convert(%Transaction{
         money: money,
         description: description,
         kind: kind,
         reported_date: reported_date,
         uuid: uuid,
         account: %Account{uuid: account_uuid, name: name},
         entry: %Entry{uuid: entry_uuid}
       }) do
    %{
      "uuid" => uuid,
      "kind" => kind,
      "description" => description,
      "reported_date" => DateTime.to_iso8601(reported_date),
      "amount" => Money.to_string(money),
      "account_name" => name,
      "account_uuid" => account_uuid,
      "entry_uuid" => entry_uuid
    }
  end

  defp convert(%Transaction{
         money: money,
         description: description,
         kind: kind,
         reported_date: reported_date,
         uuid: uuid
       }) do
    %{
      "uuid" => uuid,
      "kind" => kind,
      "description" => description,
      "reported_date" => DateTime.to_iso8601(reported_date),
      "amount" => Money.to_string(money)
    }
  end

  defp convert(other), do: other

  defp headers(%Account{}) do
    ["uuid", "name", "currency", "type", "owner_object", "owner_uid", "balance"]
  end

  defp headers(%Entry{}) do
    ["uuid", "description", "owner_object", "owner_uid"]
  end

  defp headers(%Transaction{}) do
    [
      "uuid",
      "kind",
      "description",
      "reported_date",
      "amount",
      "account_name",
      "account_uuid",
      "entry_uuid"
    ]
  end

  defp headers(map) when is_map(map), do: Map.keys(map)
end

# https://hexdocs.pm/plug/1.8.1/Plug.Conn.html#send_file/5
