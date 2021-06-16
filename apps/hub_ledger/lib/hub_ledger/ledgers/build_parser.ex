defmodule HubLedger.Ledgers.BuildParser do
  alias HubLedger.Accounts
  alias HubLedger.Accounts.Account
  alias HubLedger.Ledgers.{Entry, EntryBuilder, Transaction}

  @doc """
  Parses an entry_builder swapping the values of the entry with the payloads values.
  And returns the modify Entry and Transactions.

  payload = %{
  "commission" => "200",
  "company_app_id" => "app_12345",
  "payment_amount" => "10000",
  "payment_company_code" => "200",
  "system_fee" => "500",
  "total_fees" => "700",
  "transportation_fee" => "300",
  "use_app_transaction_id" => "use_app_1234",
  "user_id" => "user_1234"
  }
  entry = %{
    "description" => %{
      "string" => "user_id.purchase.company_app_id",
      "values" => ["user_id", "company_app_id"]
    },
    "owner" => %{
      "object" => "UseAppTransaction",
      "uid" => %{
        "string" => "use_app_transaction_id",
        "values" => ["use_app_transaction_id"]
      }
    }
  }
  [
  %{
    "account_uid" => %{
      "object" => "Hubsynch.Company",
      "uid" => "company_app_id"
    },
    "description" => %{
      "string" => "company_app_id.total.credit",
      "values" => ["company_app_id"]
    },
    "kind" => "credit",
    "money" => %{"amount" => "payment_amount", "currency" => "JPY"}
  },
  transactions = %{
    "account_uid" => %{
      "object" => "Hubsynch.Company",
      "uid" => "company_app_id"
    }]
  ## Examples

      iex> build(payload, %EntryBuilder{json_config: %{"entry" => entry, "transactions" => transactions}})
      {:ok, %Entry{}, transactions = [%Transaction{}, ...]}
  """
  def build(payload, %EntryBuilder{
        json_config: %{"entry" => entry, "transactions" => transactions}
      })
      when is_list(transactions) do
    with {:ok, %Ecto.Changeset{} = entry_changeset} <- build_entry(payload, entry),
         {:ok, transaction_changesets} <- build_transactions(payload, transactions) do
      {:ok, entry_changeset, transaction_changesets}
    else
      {:error, message} -> {:error, message}
    end
  end

  def build(_payload, _entry), do: {:error, "invalid json config"}

  defp build_entry(payload, %{
         "description" => description,
         "owner" => %{"object" => object, "uid" => uid}
       }) do
    entry_changeset =
      %{
        description: parse_attribute(payload, description),
        owner: %{
          object: parse_attribute(payload, object),
          uid: parse_attribute(payload, uid)
        }
      }
      |> Entry.create_changeset()

    {:ok, entry_changeset}
  end

  defp build_entry(payload, %{"description" => description}) do
    {:ok, Entry.create_changeset(%{description: parse_attribute(payload, description)})}
  end

  defp build_entry(_payload, attrs), do: {:ok, Entry.create_changeset(attrs)}

  defp build_transactions(payload, transactions, built \\ [])

  defp build_transactions(_payload, [], built) do
    case Enum.all?(built, & &1.valid?) do
      true -> {:ok, built}
      false -> {:error, "transactions invalid"}
    end
  end

  defp build_transactions(payload, [transaction | transactions], built) do
    build_transactions(payload, transactions, [build_transaction(payload, transaction) | built])
  end

  defp build_transaction(payload, %{
         "money" => %{"amount" => amount, "currency" => currency},
         "description" => description,
         "kind" => kind,
         "account_uid" => account_uid
       }) do
    %{
      money: parse_money(payload, amount, currency),
      description: parse_attribute(payload, description),
      kind: kind,
      account_id: get_account(payload, account_uid)
    }
    |> Transaction.create_changeset()
  end

  defp build_transaction(_payload, attrs), do: Transaction.create_changeset(attrs)

  defp get_account(payload, %{"object" => object, "uid" => uid}) do
    with %Account{id: id} <-
           Accounts.get_account_by_owner(%{"object" => object, "uid" => payload[uid]}) do
      id
    end
  end

  defp get_account(_payload, account_uid) when is_binary(account_uid) do
    with %Account{id: id} <- Accounts.get_account(%{uuid: account_uid}) do
      id
    end
  end

  defp get_account(_payload, _), do: nil

  defp parse_attribute(payload, %{"string" => attribute, "values" => values})
       when is_list(values) do
    replace(attribute, values, payload)
  end

  defp parse_attribute(_payload, attribute) when is_binary(attribute), do: attribute

  defp parse_money(payload, amount, currency) do
    with new_value when is_binary(new_value) <- payload[amount],
         {int_value, _} <- Integer.parse(new_value) do
      Money.new(int_value, currency)
    else
      new_value when is_integer(new_value) -> Money.new(new_value, currency)
      _ -> {:error, "Invalid amount"}
    end
  end

  defp replace(attribute, [], _payload), do: attribute

  # Replace a part of an attribute that is equals to a value with payload["value"].

  # ## Examples

  #     iex> replace("user_1234.purchase.company_app_id", ["company_app_id" | values], %{company_app_id: "app_12345"})
  #     "user_1234.purchase.app_12345"

  defp replace(attribute, [value | values], payload) do
    case payload[value] do
      nil ->
        replace(attribute, values, payload)

      new_value ->
        String.replace(attribute, value, new_value)
        |> replace(values, payload)
    end
  end
end
