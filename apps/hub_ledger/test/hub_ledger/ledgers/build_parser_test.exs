defmodule HubLedger.Ledgers.BuildParserTest do
  use HubLedger.DataCase

  alias HubLedger.Ledgers.BuildParser

  describe "build/2" do
    test "returns valid entries and transactions" do
      accounts = create_accounts()
      {payments, trans_exp, expense, company_a, hubsynch_fees} = accounts

      entry_builder =
        insert(:entry_builder, %{
          json_config: %{
            "entry" => entry(),
            "transactions" => transactions(accounts)
          }
        })

      {:ok, entry, transactions} = BuildParser.build(hubsynch_payload(), entry_builder)

      assert entry.valid?
      assert entry.changes[:description] == "user_1234.purchase.app_12345"
      assert entry.changes[:owner].valid?

      assert entry.changes[:owner].changes == %{
               object: "UseAppTransaction",
               uid: "use_app_1234"
             }

      # Payment total transaction
      payment_total =
        Enum.find(transactions, fn transaction ->
          transaction.changes[:description] == "app_12345.total.debit"
        end)

      assert payment_total.valid?
      assert payment_total.changes[:money] == %Money{amount: 10000, currency: :JPY}
      assert payment_total.changes[:account_id] == payments.id
      assert payment_total.changes[:kind] == "debit"

      # Transportation fee transactions
      transportation_fee_credit =
        Enum.find(transactions, fn transaction ->
          transaction.changes[:description] == "app_12345.transportion_expense.credit"
        end)

      assert transportation_fee_credit.valid?
      assert transportation_fee_credit.changes[:money] == %Money{amount: 300, currency: :JPY}
      assert transportation_fee_credit.changes[:account_id] == payments.id
      assert transportation_fee_credit.changes[:kind] == "credit"

      transportation_fee_debit =
        Enum.find(transactions, fn transaction ->
          transaction.changes[:description] == "app_12345.transportion_expense.debit"
        end)

      assert transportation_fee_debit.valid?
      assert transportation_fee_debit.changes[:money] == %Money{amount: 300, currency: :JPY}
      assert transportation_fee_debit.changes[:account_id] == trans_exp.id
      assert transportation_fee_debit.changes[:kind] == "debit"

      # Commision transactions
      commission_credit =
        Enum.find(transactions, fn transaction ->
          transaction.changes[:description] == "app_12345.transaction_expense.credit"
        end)

      assert commission_credit.valid?
      assert commission_credit.changes[:money] == %Money{amount: 200, currency: :JPY}
      assert commission_credit.changes[:account_id] == payments.id
      assert commission_credit.changes[:kind] == "credit"

      commission_debit =
        Enum.find(transactions, fn transaction ->
          transaction.changes[:description] == "app_12345.transaction_expense.debit"
        end)

      assert commission_debit.valid?
      assert commission_debit.changes[:money] == %Money{amount: 200, currency: :JPY}
      assert commission_debit.changes[:account_id] == expense.id
      assert commission_debit.changes[:kind] == "debit"

      # Net proceeds transactions
      proceeds_credit =
        Enum.find(transactions, fn transaction ->
          transaction.changes[:description] == "app_12345.proceeds.credit" &&
            transaction.changes[:account_id] == payments.id
        end)

      assert proceeds_credit.valid?
      assert proceeds_credit.changes[:money] == %Money{amount: 9000, currency: :JPY}
      assert proceeds_credit.changes[:kind] == "credit"

      proceeds_company_credit =
        Enum.find(transactions, fn transaction ->
          transaction.changes[:description] == "app_12345.proceeds.credit" &&
            transaction.changes[:account_id] == company_a.id
        end)

      assert proceeds_company_credit.valid?
      assert proceeds_company_credit.changes[:money] == %Money{amount: 9000, currency: :JPY}
      assert proceeds_company_credit.changes[:kind] == "credit"

      # Hubsynch fee transaction
      hubsynch_credit =
        Enum.find(transactions, fn transaction ->
          transaction.changes[:description] == "app_12345.hubsynch_fee.credit"
        end)

      assert hubsynch_credit.valid?
      assert hubsynch_credit.changes[:money] == %Money{amount: 500, currency: :JPY}
      assert hubsynch_credit.changes[:account_id] == hubsynch_fees.id
      assert hubsynch_credit.changes[:kind] == "credit"
    end

    test "with invalid config returns error" do
      entry_builder = insert(:entry_builder, %{json_config: %{}})

      assert {:error, "invalid json config"} ==
               BuildParser.build(hubsynch_payload(), entry_builder)
    end

    test "with invalid entry returns entry error changeset" do
      accounts = create_accounts()

      entry_builder =
        insert(:entry_builder, %{
          json_config: %{
            "entry" => %{},
            "transactions" => transactions(accounts)
          }
        })

      {:ok, entry, transactions} = BuildParser.build(hubsynch_payload(), entry_builder)
      refute entry.valid?
      assert Enum.all?(transactions, fn transaction -> transaction.valid? end)
    end

    test "with invalid transaction returns error changeset" do
      entry_builder =
        insert(:entry_builder, %{
          json_config: %{
            "entry" => entry(),
            "transactions" => [%{}]
          }
        })

      assert {:error, "transactions invalid"} ==
               BuildParser.build(hubsynch_payload(), entry_builder)
    end

    test "with invalid account returns transaction error changeset" do
      entry_builder =
        insert(:entry_builder, %{
          json_config: %{
            "entry" => entry(),
            "transactions" => [
              %{
                "money" => %{
                  "amount" => "transportation_fee",
                  "currency" => "JPY"
                },
                "description" => %{
                  "string" => "company_app_id.transportion_expense.credit",
                  "values" => ["company_app_id"]
                },
                "kind" => "credit",
                "account_uid" => %{
                  "object" => "Payments",
                  "uid" => "555"
                }
              }
            ]
          }
        })

      assert {:error, "transactions invalid"} ==
               BuildParser.build(hubsynch_payload(), entry_builder)
    end
  end

  defp hubsynch_payload do
    %{
      "user_id" => "user_1234",
      "company_app_id" => "app_12345",
      "use_app_transaction_id" => "use_app_1234",
      "payment_amount" => "10000",
      "system_fee" => "500",
      "commission" => "200",
      "net_amount" => "9000",
      "transportation_fee" => "300",
      "payment_company_code" => "200",
      "payment_type" => "purchase"
    }
  end

  defp create_accounts do
    payments =
      insert(:account, %{
        name: "Smbc.Payments",
        owner: %{object: "CreditCard.Payments", uid: "200"},
        type: "asset"
      })

    trans_exp =
      insert(:account, %{
        name: "Transportation.Expenses",
        owner: %{object: "Hubsynch"},
        type: "expense"
      })

    expense =
      insert(:account, %{
        name: "Smbc.Expenses",
        owner: %{object: "CreditCard.Expenses", uid: "200"},
        type: "expense"
      })

    company_a =
      insert(:account, %{
        name: "CompanyAppA",
        owner: %{object: "Hubsynch.Company", uid: "app_12345"},
        type: "liablity"
      })

    hubsynch_fees =
      insert(:account, %{name: "Hubsynch.Fees", owner: %{object: "Hubsynch"}, type: "revenue"})

    {payments, trans_exp, expense, company_a, hubsynch_fees}
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

  defp transactions({_payments, trans_exp, _expense, _company_a, hubsynch_fees}) do
    [
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
          "object" => "CreditCard.Payments",
          "uid" => "payment_company_code"
        }
      },
      %{
        "money" => %{
          "amount" => "transportation_fee",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.transportion_expense.credit",
          "values" => ["company_app_id"]
        },
        "kind" => "credit",
        "account_uid" => %{
          "object" => "CreditCard.Payments",
          "uid" => "payment_company_code"
        }
      },
      %{
        "money" => %{
          "amount" => "transportation_fee",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.transportion_expense.debit",
          "values" => ["company_app_id"]
        },
        "kind" => "debit",
        "account_uid" => trans_exp.uuid
      },
      %{
        "money" => %{
          "amount" => "commission",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.transaction_expense.credit",
          "values" => ["company_app_id"]
        },
        "kind" => "credit",
        "account_uid" => %{
          "object" => "CreditCard.Payments",
          "uid" => "payment_company_code"
        }
      },
      %{
        "money" => %{
          "amount" => "commission",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.transaction_expense.debit",
          "values" => ["company_app_id"]
        },
        "kind" => "debit",
        "account_uid" => %{
          "object" => "CreditCard.Expenses",
          "uid" => "payment_company_code"
        }
      },
      %{
        "money" => %{
          "amount" => "net_amount",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.proceeds.credit",
          "values" => ["company_app_id"]
        },
        "kind" => "credit",
        "account_uid" => %{
          "object" => "CreditCard.Payments",
          "uid" => "payment_company_code"
        }
      },
      %{
        "money" => %{
          "amount" => "net_amount",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.proceeds.credit",
          "values" => ["company_app_id"]
        },
        "kind" => "credit",
        "account_uid" => %{
          "object" => "Hubsynch.Company",
          "uid" => "company_app_id"
        }
      },
      %{
        "money" => %{
          "amount" => "system_fee",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.hubsynch_fee.credit",
          "values" => ["company_app_id"]
        },
        "kind" => "credit",
        "account_uid" => hubsynch_fees.uuid
      }
    ]
  end
end
