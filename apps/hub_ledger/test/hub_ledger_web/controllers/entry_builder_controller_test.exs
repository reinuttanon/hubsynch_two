defmodule HubLedgerWeb.EntryBuilderControllerTest do
  use HubLedgerWeb.ConnCase

  import HubLedger.Factory

  alias HubLedger.Ledgers

  setup :register_and_log_in_administrator

  describe "GET /" do
    test "renders new Entry Builder page", %{conn: conn} do
      conn = get(conn, Routes.entry_builder_path(conn, :new))
      response = html_response(conn, 200)

      assert response =~ "<h1>New Entry Builder</h1>"
    end

    test "renders edit Account page", %{conn: conn} do
      entry_builder = insert(:entry_builder)
      conn = get(conn, Routes.entry_builder_path(conn, :edit, entry_builder.id))
      response = html_response(conn, 200)

      assert response =~ "<h1>Edit Entry Builder</h1>"
    end

    test "renders index Account page", %{conn: conn} do
      conn = get(conn, Routes.entry_builder_path(conn, :index))
      response = html_response(conn, 200)

      assert response != nil
    end
  end

  describe "POST /" do
    test "Creates an entry builder with valid params", %{conn: conn} do
      accounts = create_accounts()

      json_config = %{
        "entry" => entry(),
        "transactions" => transactions(accounts)
      }

      entry_builder_params = %{
        active: true,
        name: "ErinTest",
        json_config: json_config,
        string_config: Jason.encode!(json_config)
      }

      conn
      |> post("/entry_builders", %{entry_builder: entry_builder_params})

      [entry_builder] = Ledgers.list_entry_builders()

      assert entry_builder != nil
      assert entry_builder.active == true
      assert entry_builder.name == "ErinTest"
      assert entry_builder.json_config == json_config
    end

    test "redirect to new entry builder view with invalid params", %{conn: conn} do
      entry_builder_params = %{
        active: true,
        name: "ErinTest",
        string_config: nil
      }

      conn =
        conn
        |> post("/entry_builders", %{entry_builder: entry_builder_params})

      response = html_response(conn, 200)
      entry_builders = Ledgers.list_entry_builders()

      assert length(entry_builders) == 0
      assert response =~ "<h1>New Entry Builder</h1>"
    end
  end

  defp create_accounts do
    payments =
      insert(:account, %{
        name: "Smbc.Payments",
        owner: %{object: "Payments", uid: "200"},
        type: "asset",
        kind: "debit"
      })

    trans_liab =
      insert(:account, %{
        name: "Transportation.Payables",
        owner: %{object: "Hubsynch"},
        type: "liability",
        kind: "credit"
      })

    insert(:account, %{
      name: "Smbc.Payables",
      owner: %{object: "Payables", uid: "200"},
      type: "liability",
      kind: "credit"
    })

    expense =
      insert(:account, %{
        name: "Smbc.Expenses",
        owner: %{object: "Expenses", uid: "200"},
        type: "expense",
        kind: "debit"
      })

    company_a =
      insert(:account, %{
        name: "CompanyAppA",
        owner: %{object: "Hubsynch.Company", uid: "app_12345"},
        type: "liablity",
        kind: "credit"
      })

    hubsynch_fees =
      insert(:account, %{name: "Hubsynch.Fees", owner: %{object: "Hubsynch"}, type: "revenue"})

    {payments, trans_liab, expense, company_a, hubsynch_fees}
  end

  defp entry do
    %{
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
  end

  defp transactions(_) do
    [
      # debit Payments asset 10000
      %{
        "money" => %{
          "amount" => "payment_amount",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.total.debit",
          "values" => ["company_app_id"]
        },
        "kind" => "debit",
        "account_uid" => %{
          "object" => "Payments",
          "uid" => "payment_company_code"
        }
      },
      # credit Company liability 10000
      %{
        "money" => %{
          "amount" => "payment_amount",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.total.credit",
          "values" => ["company_app_id"]
        },
        "kind" => "credit",
        "account_uid" => %{
          "object" => "Hubsynch.Company",
          "uid" => "company_app_id"
        }
      }
    ]
  end
end
