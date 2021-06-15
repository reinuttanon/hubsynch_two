defmodule HubLedger.Reports.Accounts do
  import Ecto.Query, warn: false

  alias HubLedger.Accounts.Account
  alias HubLedger.Ledgers
  alias HubLedger.Reports.AccountFilters
  alias HubLedger.Repo

  @valid_keys [
    :active,
    :currency,
    :from_date,
    :kind,
    :name,
    :owner,
    :order_by,
    :to_date,
    :type,
    :uuid,
    :uuids
  ]

  def generate(%{"report_type" => "balances"} = report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> Map.delete(:from_date)
    |> Map.delete(:to_date)
    |> generate_data(Account)
    |> all()
    |> Enum.map(fn account -> generate_balances(account, report_params) end)
  end

  def generate(report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> generate_data(Account)
    |> all()
  end

  def generate_count(report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> generate_data(Account)
    |> count()
  end

  def generate_sample(%{"report_type" => "balances"} = report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> Map.delete(:from_date)
    |> Map.delete(:to_date)
    |> generate_data(Account)
    |> sample()
    |> Enum.map(fn account -> generate_balances(account, report_params) end)
  end

  def generate_sample(report_params) do
    Enum.map(report_params, fn {key, value} -> convert_key(key, value) end)
    |> Enum.reject(fn value -> value == nil end)
    |> Enum.into(%{})
    |> generate_data(Account)
    |> sample()
  end

  defp convert_key("active", value), do: {:active, value}

  defp convert_key("currency", value), do: {:currency, value}

  defp convert_key("from_date", value), do: {:from_date, value}

  defp convert_key("kind", value), do: {:kind, value}

  defp convert_key("name", value), do: {:name, value}

  defp convert_key("owner", %{"object" => object, "uid" => uid}),
    do: {:owner, %{object: object, uid: uid}}

  defp convert_key("owner", %{"object" => object}), do: {:owner, %{object: object}}

  defp convert_key("owner", %{"uid" => uid}), do: {:owner, %{uid: uid}}

  defp convert_key("order_by", value), do: {:order_by, value}

  defp convert_key("to_date", value), do: {:to_date, value}

  defp convert_key("type", value), do: {:type, value}

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
      apply(AccountFilters, key, [acc, value])
    end)
  end

  defp all({:error, message}), do: {:error, message}

  defp all(report_query) do
    report_query
    |> AccountFilters.preload(:balance)
    |> Repo.all()
  end

  defp sample({:error, message}), do: {:error, message}

  defp sample(report_query) do
    query =
      from q in report_query,
        limit: 15

    query
    |> AccountFilters.preload(:balance)
    |> Repo.all()
  end

  defp count({:error, message}), do: {:error, message}

  defp count(report_query) do
    report_query
    |> Repo.aggregate(:count, :id)
  end

  defp generate_balances(%Account{id: id, kind: kind} = account, %{
         "from_date" => from_date,
         "to_date" => to_date
       }) do
    credits =
      Ledgers.sum_transactions(%{
        account_id: id,
        kind: "credit",
        from_date: from_date,
        to_date: to_date
      })

    debits =
      Ledgers.sum_transactions(%{
        account_id: id,
        kind: "debit",
        from_date: from_date,
        to_date: to_date
      })

    %{
      name: account.name,
      currency: account.currency,
      uuid: account.uuid,
      from_date: from_date,
      to_date: to_date,
      amount: total(credits, debits, kind)
    }
  end

  defp generate_balances(%Account{id: id, kind: kind} = account, %{
         "from_date" => from_date
       }) do
    credits = Ledgers.sum_transactions(%{account_id: id, kind: "credit", from_date: from_date})
    debits = Ledgers.sum_transactions(%{account_id: id, kind: "debit", from_date: from_date})

    %{
      name: account.name,
      currency: account.currency,
      uuid: account.uuid,
      from_date: from_date,
      to_date: "",
      amount: total(credits, debits, kind)
    }
  end

  defp generate_balances(%Account{id: id, kind: kind} = account, %{
         "to_date" => to_date
       }) do
    credits = Ledgers.sum_transactions(%{account_id: id, kind: "credit", to_date: to_date})
    debits = Ledgers.sum_transactions(%{account_id: id, kind: "debit", to_date: to_date})

    %{
      name: account.name,
      currency: account.currency,
      uuid: account.uuid,
      from_date: "",
      to_date: to_date,
      amount: total(credits, debits, kind)
    }
  end

  defp generate_balances(%Account{id: id, kind: kind} = account, _) do
    credits = Ledgers.sum_transactions(%{account_id: id, kind: "credit"})
    debits = Ledgers.sum_transactions(%{account_id: id, kind: "debit"})

    %{
      name: account.name,
      currency: account.currency,
      uuid: account.uuid,
      from_date: "",
      to_date: "",
      amount: total(credits, debits, kind)
    }
  end

  defp total(credits, debits, "credit"), do: credits - debits

  defp total(credits, debits, "debit"), do: debits - credits
end
