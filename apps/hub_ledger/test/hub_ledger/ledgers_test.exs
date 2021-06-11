defmodule HubLedger.LedgersTest do
  use HubLedger.DataCase

  alias HubLedger.{Accounts, Ledgers, Repo}
  alias HubLedger.Accounts.Balance

  describe "create_journal_entry/2" do
    test "returns ok with the entry and transactions" do
      accounts = create_accounts()

      {payments, trans_liab, liability, expense, company_a, hubsynch_fees} = accounts

      entry_builder =
        insert(:entry_builder, %{
          json_config: %{
            "entry" => entry(),
            "transactions" => transactions(accounts)
          }
        })

      assert {:ok, %{entry: entry, transactions: {9, transactions}}} =
               Ledgers.create_journal_entry(hubsynch_payload(), entry_builder.uuid)

      assert entry.description == "user_1234.purchase.app_12345"
      assert entry.owner.object == "UseAppTransaction"
      assert entry.owner.uid == "use_app_1234"

      total_debit = Enum.find(transactions, &(&1.description == "app_12345.total.debit"))
      assert total_debit.entry_id == entry.id
      assert total_debit.kind == "debit"
      assert total_debit.money.amount == 10000
      assert total_debit.account_id == payments.id

      # credit Company liability 10000
      total_credit = Enum.find(transactions, &(&1.description == "app_12345.total.credit"))
      assert total_credit.entry_id == entry.id
      assert total_credit.kind == "credit"
      assert total_credit.money.amount == 10000
      assert total_credit.account_id == company_a.id

      # debit Company liability 300
      comp_debit =
        Enum.find(transactions, &(&1.description == "app_12345.transportion_expense.debit"))

      assert comp_debit.entry_id == entry.id
      assert comp_debit.kind == "debit"
      assert comp_debit.money.amount == 300
      assert comp_debit.account_id == company_a.id

      # credit Transport liablity 300
      trans_credit =
        Enum.find(transactions, &(&1.description == "app_12345.transportion_payables.credit"))

      assert trans_credit.entry_id == entry.id
      assert trans_credit.kind == "credit"
      assert trans_credit.money.amount == 300
      assert trans_credit.account_id == trans_liab.id

      # debit Company liablity 700
      comp_fee_debit = Enum.find(transactions, &(&1.description == "app_12345.total_fees.debit"))
      assert comp_fee_debit.entry_id == entry.id
      assert comp_fee_debit.kind == "debit"
      assert comp_fee_debit.money.amount == 700
      assert comp_fee_debit.account_id == company_a.id

      # credit Payables liability 200
      liability_credit =
        Enum.find(transactions, &(&1.description == "app_12345.transaction_payables.credit"))

      assert liability_credit.entry_id == entry.id
      assert liability_credit.kind == "credit"
      assert liability_credit.money.amount == 200
      assert liability_credit.account_id == liability.id

      # credit Fees revenue 500
      fee_credit = Enum.find(transactions, &(&1.description == "app_12345.hubsynch_fee.credit"))
      assert fee_credit.entry_id == entry.id
      assert fee_credit.kind == "credit"
      assert fee_credit.money.amount == 500
      assert fee_credit.account_id == hubsynch_fees.id

      # credit Payments asset 200
      payments_credit =
        Enum.find(transactions, &(&1.description == "app_12345.transaction_expense.credit"))

      assert payments_credit.entry_id == entry.id
      assert payments_credit.kind == "credit"
      assert payments_credit.money.amount == 200
      assert payments_credit.account_id == payments.id

      # debit Expenses expense 200
      expense_debit =
        Enum.find(transactions, &(&1.description == "app_12345.transaction_expense.debit"))

      assert expense_debit.entry_id == entry.id
      assert expense_debit.kind == "debit"
      assert expense_debit.money.amount == 200
      assert expense_debit.account_id == expense.id
    end

    test "updates all running balances" do
      accounts = create_accounts()

      {payments, trans_liab, liability, expense, company_a, hubsynch_fees} = accounts

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: payments.id})

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: trans_liab.id})

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: liability.id})

      assert %Balance{money: %Money{amount: 0}} = Accounts.get_balance!(%{account_id: expense.id})

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: company_a.id})

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: hubsynch_fees.id})

      entry_builder =
        insert(:entry_builder, %{
          json_config: %{
            "entry" => entry(),
            "transactions" => transactions(accounts)
          }
        })

      for _ <- 1..3 do
        assert {:ok, %{transactions: {9, _}}} =
                 Ledgers.create_journal_entry(hubsynch_payload(), entry_builder.uuid)
      end

      assert %Balance{money: %Money{amount: 30000}} =
               Accounts.get_balance!(%{account_id: payments.id})

      assert %Balance{money: %Money{amount: 900}} =
               Accounts.get_balance!(%{account_id: trans_liab.id})

      assert %Balance{money: %Money{amount: 600}} =
               Accounts.get_balance!(%{account_id: liability.id})

      assert %Balance{money: %Money{amount: 600}} =
               Accounts.get_balance!(%{account_id: expense.id})

      assert %Balance{money: %Money{amount: 30000}} =
               Accounts.get_balance!(%{account_id: company_a.id})

      assert %Balance{money: %Money{amount: 1500}} =
               Accounts.get_balance!(%{account_id: hubsynch_fees.id})
    end

    test "retuns created transactions and error if transactions don't balance" do
      accounts = create_accounts()

      [_hd | transactions] = transactions(accounts)

      entry_builder =
        insert(:entry_builder, %{
          json_config: %{
            "entry" => entry(),
            "transactions" => transactions
          }
        })

      assert {:error, message, %{transactions: {8, _transactions}}} =
               Ledgers.create_journal_entry(hubsynch_payload(), entry_builder.uuid)

      assert message == "transactions do not balance"
    end

    test "returns error with invalid entry_builder" do
      assert {:error, "invalid entry builder"} ==
               Ledgers.create_journal_entry(hubsynch_payload(), "nooupe")
    end
  end

  describe "safe_journal_entry/2" do
    test "returns ok with the entry and transactions" do
      accounts = create_accounts()
      {payments, trans_liab, liability, expense, company_a, hubsynch_fees} = accounts

      entry_builder =
        insert(:entry_builder, %{
          json_config: %{
            "entry" => entry(),
            "transactions" => transactions(accounts)
          }
        })

      assert {:ok, %{entry: entry, transactions: {9, transactions}}} =
               Ledgers.safe_journal_entry(hubsynch_payload(), entry_builder.uuid)

      assert entry.description == "user_1234.purchase.app_12345"
      assert entry.owner.object == "UseAppTransaction"
      assert entry.owner.uid == "use_app_1234"

      total_debit = Enum.find(transactions, &(&1.description == "app_12345.total.debit"))
      assert total_debit.entry_id == entry.id
      assert total_debit.kind == "debit"
      assert total_debit.money.amount == 10000
      assert total_debit.account_id == payments.id

      # credit Company liability 10000
      total_credit = Enum.find(transactions, &(&1.description == "app_12345.total.credit"))
      assert total_credit.entry_id == entry.id
      assert total_credit.kind == "credit"
      assert total_credit.money.amount == 10000
      assert total_credit.account_id == company_a.id

      # debit Company liability 300
      comp_debit =
        Enum.find(transactions, &(&1.description == "app_12345.transportion_expense.debit"))

      assert comp_debit.entry_id == entry.id
      assert comp_debit.kind == "debit"
      assert comp_debit.money.amount == 300
      assert comp_debit.account_id == company_a.id

      # credit Transport liablity 300
      trans_credit =
        Enum.find(transactions, &(&1.description == "app_12345.transportion_payables.credit"))

      assert trans_credit.entry_id == entry.id
      assert trans_credit.kind == "credit"
      assert trans_credit.money.amount == 300
      assert trans_credit.account_id == trans_liab.id

      # debit Company liablity 700
      comp_fee_debit = Enum.find(transactions, &(&1.description == "app_12345.total_fees.debit"))
      assert comp_fee_debit.entry_id == entry.id
      assert comp_fee_debit.kind == "debit"
      assert comp_fee_debit.money.amount == 700
      assert comp_fee_debit.account_id == company_a.id

      # credit Payables liability 200
      liability_credit =
        Enum.find(transactions, &(&1.description == "app_12345.transaction_payables.credit"))

      assert liability_credit.entry_id == entry.id
      assert liability_credit.kind == "credit"
      assert liability_credit.money.amount == 200
      assert liability_credit.account_id == liability.id

      # credit Fees revenue 500
      fee_credit = Enum.find(transactions, &(&1.description == "app_12345.hubsynch_fee.credit"))
      assert fee_credit.entry_id == entry.id
      assert fee_credit.kind == "credit"
      assert fee_credit.money.amount == 500
      assert fee_credit.account_id == hubsynch_fees.id

      # credit Payments asset 200
      payments_credit =
        Enum.find(transactions, &(&1.description == "app_12345.transaction_expense.credit"))

      assert payments_credit.entry_id == entry.id
      assert payments_credit.kind == "credit"
      assert payments_credit.money.amount == 200
      assert payments_credit.account_id == payments.id

      # debit Expenses expense 200
      expense_debit =
        Enum.find(transactions, &(&1.description == "app_12345.transaction_expense.debit"))

      assert expense_debit.entry_id == entry.id
      assert expense_debit.kind == "debit"
      assert expense_debit.money.amount == 200
      assert expense_debit.account_id == expense.id
    end

    test "updates all running balances" do
      accounts = create_accounts()

      {payments, trans_liab, liability, expense, company_a, hubsynch_fees} = accounts

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: payments.id})

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: trans_liab.id})

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: liability.id})

      assert %Balance{money: %Money{amount: 0}} = Accounts.get_balance!(%{account_id: expense.id})

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: company_a.id})

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: hubsynch_fees.id})

      entry_builder =
        insert(:entry_builder, %{
          json_config: %{
            "entry" => entry(),
            "transactions" => transactions(accounts)
          }
        })

      for _ <- 1..3 do
        assert {:ok, %{transactions: {9, _}}} =
                 Ledgers.safe_journal_entry(hubsynch_payload(), entry_builder.uuid)
      end

      assert %Balance{money: %Money{amount: 30000}} =
               Accounts.get_balance!(%{account_id: payments.id})

      assert %Balance{money: %Money{amount: 900}} =
               Accounts.get_balance!(%{account_id: trans_liab.id})

      assert %Balance{money: %Money{amount: 600}} =
               Accounts.get_balance!(%{account_id: liability.id})

      assert %Balance{money: %Money{amount: 600}} =
               Accounts.get_balance!(%{account_id: expense.id})

      assert %Balance{money: %Money{amount: 30000}} =
               Accounts.get_balance!(%{account_id: company_a.id})

      assert %Balance{money: %Money{amount: 1500}} =
               Accounts.get_balance!(%{account_id: hubsynch_fees.id})
    end

    test "retuns error if transactions don't balance" do
      accounts = create_accounts()

      [_hd | transactions] = transactions(accounts)

      entry_builder =
        insert(:entry_builder, %{
          json_config: %{
            "entry" => entry(),
            "transactions" => transactions
          }
        })

      assert {:error, message} =
               Ledgers.safe_journal_entry(hubsynch_payload(), entry_builder.uuid)

      assert message == "transactions do not balance"
    end

    test "returns error with invalid entry_builder" do
      assert {:error, "invalid entry builder"} ==
               Ledgers.safe_journal_entry(hubsynch_payload(), "nooupe")
    end
  end

  describe "journal_entry/2" do
    test "with valid entry and transactions returns ok tuple" do
      build_transactions = [
        build_transaction(1000, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(100, "credit", insert(:account, %{kind: "credit"})),
        build_transaction(700, "credit", insert(:account, %{kind: "credit"}))
      ]

      build_entry = HubLedger.Ledgers.Entry.create_changeset(%{description: "big pillows"})

      assert {:ok, %{entry: entry, transactions: {3, transactions}}} =
               Ledgers.journal_entry(build_entry, build_transactions)

      assert entry.description == "big pillows"
      refute entry.uuid == nil

      assert Enum.all?(transactions, &(&1.uuid != nil))
    end

    test "updates all running balances" do
      payments =
        insert(:account, %{
          name: "Smbc.Payments",
          owner: %{object: "Payments", uid: "200"},
          type: "asset",
          kind: "debit"
        })

      liability =
        insert(:account, %{
          name: "Smbc.Payables",
          owner: %{object: "Payables", uid: "200"},
          type: "liability",
          kind: "credit"
        })

      company_a =
        insert(:account, %{
          name: "CompanyAppA",
          owner: %{object: "Hubsynch.Company", uid: "app_12345"},
          type: "liablity",
          kind: "credit"
        })

      [payments, liability, company_a]
      |> Enum.each(fn account -> Accounts.Balance.create_changeset(account) |> Repo.insert() end)

      build_transactions = [
        build_transaction(1000, "debit", payments),
        build_transaction(100, "credit", liability),
        build_transaction(700, "credit", company_a)
      ]

      build_entry = HubLedger.Ledgers.Entry.create_changeset(%{description: "big pillows"})

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: payments.id})

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: company_a.id})

      assert %Balance{money: %Money{amount: 0}} =
               Accounts.get_balance!(%{account_id: liability.id})

      for _ <- 1..3 do
        assert {:ok, %{transactions: {3, _}}} =
                 Ledgers.journal_entry(build_entry, build_transactions)
      end

      assert %Balance{money: %Money{amount: 3000}} =
               Accounts.get_balance!(%{account_id: payments.id})

      assert %Balance{money: %Money{amount: 2100}} =
               Accounts.get_balance!(%{account_id: company_a.id})

      assert %Balance{money: %Money{amount: 300}} =
               Accounts.get_balance!(%{account_id: liability.id})
    end

    test "with invalid entry returns error" do
      build_transactions = [
        build_transaction(1000, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(100, "credit", insert(:account, %{kind: "credit"})),
        build_transaction(700, "credit", insert(:account, %{kind: "credit"}))
      ]

      build_entry = HubLedger.Ledgers.Entry.create_changeset(%{})

      assert {:error, %{entry: entry_changeset, transactions: _}} =
               Ledgers.journal_entry(build_entry, build_transactions)

      refute entry_changeset.valid?
      assert entry_changeset.errors[:description] == {"can't be blank", [validation: :required]}
    end

    test "with invalid transaction returns error" do
      transactions = [
        build_transaction(1000, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(100, "credit", insert(:account, %{kind: "credit"})),
        build_transaction(700, "credit", insert(:account, %{kind: "credit"}))
      ]

      bad_transaction =
        HubLedger.Ledgers.Transaction.create_changeset(%{money: Money.new(100, "JPY")})

      build_entry = HubLedger.Ledgers.Entry.create_changeset(%{description: "big pillows"})

      assert {:error, %{transactions: transactions}} =
               Ledgers.journal_entry(build_entry, [bad_transaction | transactions])

      bad_changeset = Enum.find(transactions, &(!&1.valid?))
      refute bad_changeset.valid?
      assert bad_changeset.errors[:description] == {"can't be blank", [validation: :required]}
      assert bad_changeset.errors[:kind] == {"can't be blank", [validation: :required]}
      assert bad_changeset.errors[:account_id] == {"can't be blank", [validation: :required]}
    end
  end

  describe "sum_transactions/1" do
    test "reurns the sum of all the transactions with the account and kind" do
      account_1 = insert(:account, %{currency: "JPY"})
      account_2 = insert(:account, %{currency: "JPY"})

      for _ <- 1..3 do
        insert(:transaction, %{
          account: account_1,
          kind: "credit",
          money: Money.new(500, "JPY")
        })

        insert(:transaction, %{
          account: account_1,
          kind: "debit",
          money: Money.new(200, "JPY")
        })

        insert(:transaction, %{
          account: account_2,
          kind: "credit",
          money: Money.new(600, "JPY")
        })
      end

      assert Ledgers.sum_transactions(%{account_id: account_1.id, kind: "credit"}) == 1500
    end

    test "returns the balance for a to_date" do
      account = insert(:account, type: "revenue")
      %{now: now, one_week_ago: _one_week_ago} = historical_transactions(account)

      three_days_ago = DateTime.add(now, -259_200)

      credit_total =
        Ledgers.sum_transactions(%{
          account_id: account.id,
          kind: "credit",
          to_date: three_days_ago
        })

      debit_total =
        Ledgers.sum_transactions(%{
          account_id: account.id,
          kind: "debit",
          to_date: three_days_ago
        })

      assert credit_total == 4_000
      assert debit_total == 40_000
    end

    test "returns 0 if no transactions" do
      account = insert(:account)

      assert Ledgers.sum_transactions(%{account_id: account.id, kind: "credit"}) == 0
    end
  end

  defp build_transaction(amount, kind, account) do
    %{
      money: Money.new(amount, "JPY"),
      description: "test.pay.#{kind}",
      kind: kind,
      account_id: account.id
    }
    |> HubLedger.Ledgers.Transaction.create_changeset()
  end

  defp hubsynch_payload do
    %{
      "user_id" => "user_1234",
      "company_app_id" => "app_12345",
      "use_app_transaction_id" => "use_app_1234",
      "payment_amount" => "10000",
      "system_fee" => "500",
      "commission" => "200",
      "total_fees" => "700",
      "transportation_fee" => "300",
      "payment_company_code" => "200"
    }
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

    liability =
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
      insert(:account, %{
        name: "Hubsynch.Fees",
        owner: %{object: "Hubsynch"},
        type: "revenue",
        kind: "credit"
      })

    [payments, trans_liab, liability, expense, company_a, hubsynch_fees]
    |> Enum.each(fn account -> Accounts.Balance.create_changeset(account) |> Repo.insert() end)

    {payments, trans_liab, liability, expense, company_a, hubsynch_fees}
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

  defp transactions({_payments, trans_liab, _liability, _expense, _company_a, hubsynch_fees}) do
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
      },
      # debit Company liability 300
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
        "account_uid" => %{
          "object" => "Hubsynch.Company",
          "uid" => "company_app_id"
        }
      },
      # credit Transport liablity 300
      %{
        "money" => %{
          "amount" => "transportation_fee",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.transportion_payables.credit",
          "values" => ["company_app_id"]
        },
        "kind" => "credit",
        "account_uid" => trans_liab.uuid
      },
      # debit Company liablity 700
      %{
        "money" => %{
          "amount" => "total_fees",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.total_fees.debit",
          "values" => ["company_app_id"]
        },
        "kind" => "debit",
        "account_uid" => %{
          "object" => "Hubsynch.Company",
          "uid" => "company_app_id"
        }
      },
      # credit Payables liability 200
      %{
        "money" => %{
          "amount" => "commission",
          "currency" => "JPY"
        },
        "description" => %{
          "string" => "company_app_id.transaction_payables.credit",
          "values" => ["company_app_id"]
        },
        "kind" => "credit",
        "account_uid" => %{
          "object" => "Payables",
          "uid" => "payment_company_code"
        }
      },
      # credit Fees revenue 500
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
      },
      # credit Payments asset 200
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
          "object" => "Payments",
          "uid" => "payment_company_code"
        }
      },
      # debit Expenses expense 200
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
          "object" => "Expenses",
          "uid" => "payment_company_code"
        }
      }
    ]
  end

  defp historical_transactions(account) do
    one_week = 604_800
    one_day = 86_400

    now =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    one_week_ago = DateTime.add(now, -one_week)

    for index <- 1..7 do
      increment_one_day = DateTime.add(one_week_ago, index * one_day)
      _decrement_one_day = DateTime.add(one_week_ago, -(index * one_day))

      insert(:transaction,
        account: account,
        kind: "debit",
        money: Money.new(10_000, "JPY"),
        reported_date: increment_one_day
      )

      insert(:transaction,
        account: account,
        reported_date: increment_one_day,
        kind: "credit",
        money: Money.new(1_000, "JPY")
      )
    end

    %{
      now: now,
      one_week_ago: one_week_ago
    }
  end
end
