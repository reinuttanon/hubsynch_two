defmodule HubLedger.Reports.Transactions do
  import Ecto.Query, warn: false

  alias HubLedger.{Accounts, Ledgers, Repo}
  alias HubLedger.Accounts.Account
  alias HubLedger.Ledgers.{Entry, Transaction}
  alias HubLedger.Reports.TransactionFilters

  @valid_keys [
    :account_id,
    :account_uuid,
    :description,
    :entry_id,
    :entry_uuid,
    :entry_description,
    :from_date,
    :kind,
    :order_by,
    :to_date
  ]

  def generate(report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> generate_data()
    |> all()
  end

  def generate_count(report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> generate_data()
    |> count()
  end

  def generate_sample(report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> generate_data()
    |> sample()
  end

  defp convert_key(key, value) when is_atom(key) do
    case Enum.member?(@valid_keys, key) do
      true -> {key, value}
      _ -> nil
    end
  end

  defp convert_key("account_id", value), do: {:account_id, value}

  defp convert_key("account_uuid", value), do: {:account_uuid, value}

  defp convert_key("account_uuids", value), do: {:account_uuids, value}

  defp convert_key("description", value), do: {:description, value}

  defp convert_key("entry_id", value), do: {:entry_id, value}

  defp convert_key("entry_uuid", value), do: {:entry_uuid, value}

  defp convert_key("entry_uuids", value), do: {:entry_uuids, value}

  defp convert_key("entry_description", value), do: {:entry_description, value}

  defp convert_key("from_date", ""), do: nil

  defp convert_key("from_date", value), do: {:from_date, value}

  defp convert_key("kind", "all"), do: nil

  defp convert_key("kind", value), do: {:kind, value}

  defp convert_key("order_by", value), do: {:order_by, value}

  defp convert_key("to_date", ""), do: nil

  defp convert_key("to_date", value), do: {:to_date, value}

  defp convert_key(_, _), do: nil

  defp generate_data(%{account_uuid: account_uuid} = report_params) do
    case Accounts.get_account(%{uuid: account_uuid}) do
      %Account{id: account_id} ->
        Map.delete(report_params, :account_uuid)
        |> Map.put(:account_id, account_id)
        |> generate_data()

      _ ->
        {:error, "invalid account uuid"}
    end
  end

  defp generate_data(%{account_uuids: []} = report_params) do
    report_params
    |> Map.delete(:account_uuids)
    |> generate_data()
  end

  defp generate_data(%{account_uuids: account_uuids} = report_params) do
    account_ids =
      Account
      |> TransactionFilters.uuid(account_uuids)
      |> TransactionFilters.select_ids()
      |> Repo.all()

    report_params
    |> Map.delete(:account_uuids)
    |> Map.put(:account_id, account_ids)
    |> generate_data()
  end

  defp generate_data(%{entry_uuid: entry_uuid} = report_params) do
    case Ledgers.get_entry(%{uuid: entry_uuid}) do
      %Entry{id: entry_id} ->
        Map.delete(report_params, :entry_uuid)
        |> Map.put(:entry_id, entry_id)
        |> generate_data()

      _ ->
        {:error, "invalid entry uuid"}
    end
  end

  defp generate_data(%{entry_uuids: []} = report_params) do
    report_params
    |> Map.delete(:entry_uuids)
    |> generate_data()
  end

  defp generate_data(%{entry_uuids: entry_uuids} = report_params) do
    entry_ids =
      Entry
      |> TransactionFilters.uuid(entry_uuids)
      |> TransactionFilters.select_ids()
      |> Repo.all()

    report_params
    |> Map.delete(:entry_uuids)
    |> Map.put(:entry_id, entry_ids)
    |> generate_data()
  end

  defp generate_data(%{entry_description: entry_description} = report_params) do
    entry_ids =
      Entry
      |> TransactionFilters.description(entry_description)
      |> TransactionFilters.select_ids()
      |> Repo.all()

    report_params
    |> Map.delete(:entry_description)
    |> Map.put(:entry_id, entry_ids)
    |> generate_data()
  end

  defp generate_data(report_params) do
    Enum.reduce(report_params, Transaction, fn {key, value}, acc ->
      apply(TransactionFilters, key, [acc, value])
    end)
  end

  defp all({:error, message}), do: {:error, message}

  defp all(report_query) do
    report_query
    |> TransactionFilters.preload([:account, :entry])
    |> Repo.all()
  end

  defp sample({:error, message}), do: {:error, message}

  defp sample(report_query) do
    query =
      from q in report_query,
        limit: 15

    query
    |> TransactionFilters.preload([:account, :entry])
    |> Repo.all()
  end

  defp count({:error, message}), do: {:error, message}

  defp count(report_query) do
    report_query
    |> Repo.aggregate(:count, :id)
  end
end
