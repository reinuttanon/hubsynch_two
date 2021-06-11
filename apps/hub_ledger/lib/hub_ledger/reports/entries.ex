defmodule HubLedger.Reports.Entries do
  import Ecto.Query, warn: false

  alias HubLedger.Ledgers.Entry
  alias HubLedger.Reports.EntryFilters
  alias HubLedger.Repo

  @valid_keys [
    :description,
    :from_date,
    :order_by,
    :owner,
    :preload,
    :to_date,
    :uuid,
    :uuids
  ]

  def generate(%{"preload" => "true"} = report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> generate_data(Entry)
    |> all()
    |> Enum.map(& &1.transactions)
    |> List.flatten()
  end

  def generate(report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> generate_data(Entry)
    |> all()
  end

  def generate_count(report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> generate_data(Entry)
    |> count()
  end

  def generate_sample(%{"preload" => "true"} = report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> generate_data(Entry)
    |> sample()
    |> Enum.map(& &1.transactions)
    |> List.flatten()
  end

  def generate_sample(report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> generate_data(Entry)
    |> sample()
  end

  defp convert_key("description", value), do: {:description, value}

  defp convert_key("from_date", value), do: {:from_date, value}

  defp convert_key("order_by", value), do: {:order_by, value}

  defp convert_key("owner", %{"object" => object, "uid" => uid}),
    do: {:owner, %{object: object, uid: uid}}

  defp convert_key("owner", %{"object" => object}), do: {:owner, %{object: object}}

  defp convert_key("owner", %{"uid" => uid}), do: {:owner, %{uid: uid}}

  defp convert_key("preload", "true"), do: {:preload, [transactions: [:account, :entry]]}

  defp convert_key("preload", true), do: {:preload, [transactions: [:account, :entry]]}

  defp convert_key("preload", _), do: {:preload, :transactions}

  defp convert_key("to_date", value), do: {:to_date, value}

  defp convert_key("uuid", value), do: {:uuid, value}

  defp convert_key("uuids", []), do: nil

  defp convert_key("uuids", value), do: {:uuids, value}

  defp convert_key(key, value) when is_atom(key) do
    case Enum.member?(@valid_keys, key) do
      true -> {key, value}
      false -> nil
    end
  end

  defp convert_key(_, _), do: nil

  defp generate_data(report_params, object) do
    Enum.reduce(report_params, object, fn {key, value}, acc ->
      apply(EntryFilters, key, [acc, value])
    end)
  end

  defp all({:error, message}), do: {:error, message}

  defp all(report_query) do
    report_query
    |> Repo.all()
  end

  defp sample({:error, message}), do: {:error, message}

  defp sample(report_query) do
    query =
      from q in report_query,
        limit: 15

    query
    |> Repo.all()
  end

  defp count({:error, message}), do: {:error, message}

  defp count(report_query) do
    report_query
    |> Repo.aggregate(:count, :id)
  end
end
