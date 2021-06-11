# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     HubLedger.Repo.insert!(%HubLedger.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
accounts = [
  %{
    currency: "JPY",
    name: "UserA.Wallet",
    owner: %{object: "HubIdentity.User", uid: "UserA_uid"},
    type: "liability"
  },
  %{
    currency: "JPY",
    name: "UserB.Wallet",
    owner: %{object: "HubIdentity.User", uid: "UserB_uid"},
    type: "liability"
  },
  %{
    currency: "JPY",
    name: "BankA.Cash",
    owner: %{object: "Bank.Cash", uid: "BankA_uid"},
    type: "asset"
  },
  %{
    currency: "JPY",
    name: "BankA.Expenses",
    owner: %{object: "Bank.Expense", uid: "BankA_uid"},
    type: "expense"
  },
  %{
    currency: "JPY",
    name: "Smbc.Payments",
    owner: %{object: "CreditCard.Payments", uid: "200"},
    type: "asset"
  },
  %{
    currency: "JPY",
    name: "Smbc.Expenses",
    owner: %{object: "CreditCard.Expenses", uid: "200"},
    type: "expense"
  },
  %{
    currency: "JPY",
    name: "Smbc.Payables",
    owner: %{object: "CreditCard.Payables", uid: "200"},
    type: "liability"
  },
  %{
    currency: "JPY",
    name: "GMO.Payments",
    owner: %{object: "CreditCard.Payments", uid: "300"},
    type: "asset"
  },
  %{
    currency: "JPY",
    name: "GMO.Expenses",
    owner: %{object: "CreditCard.Expenses", uid: "300"},
    type: "expense"
  },
  %{
    currency: "JPY",
    name: "GMO.Payables",
    owner: %{object: "CreditCard.Payables", uid: "300"},
    type: "liability"
  },
  %{
    currency: "JPY",
    name: "Glay Application",
    owner: %{object: "Hubsynch.Company", uid: "app_100"},
    type: "liability"
  },
  %{
    currency: "JPY",
    name: "Hi Ticket",
    owner: %{object: "Hubsynch.Company", uid: "app_101"},
    type: "liability"
  },
  %{
    currency: "JPY",
    name: "Pizza of Death",
    owner: %{object: "Hubsynch.Company", uid: "app_102"},
    type: "liability"
  },
  %{
    currency: "JPY",
    name: "Seventeen Cafe",
    owner: %{object: "Hubsynch.Company", uid: "app_103"},
    type: "liability"
  }
]

Enum.each(accounts, &HubLedger.Accounts.create_account(&1))

{:ok, %{account: wallet_fee}} =
  HubLedger.Accounts.create_account(%{
    currency: "JPY",
    name: "WalletFees",
    owner: %{object: "Wallet.Fees", uid: "1"},
    type: "revenue"
  })

{:ok, %{account: transport_payables}} =
  HubLedger.Accounts.create_account(%{
    currency: "JPY",
    name: "Transportation.Payables",
    owner: %{object: "Hubsynch.Payables", uid: "1"},
    type: "liability"
  })

{:ok, %{account: hubsynch_fees}} =
  HubLedger.Accounts.create_account(%{
    currency: "JPY",
    name: "Hubsynch.Fees",
    owner: %{object: "Hubsynch.Fees", uid: "1"},
    type: "revenue"
  })

entry_builders = [
  %{
    json_config: %{
      "entry" => %{
        "description" => %{
          "string" => "sender.deposit.wallet",
          "values" => ["sender"]
        },
        "owner" => %{
          "object" => "DepositRequest",
          "uid" => %{"string" => "request_uid", "values" => ["request_uid"]}
        }
      },
      "transactions" => [
        %{
          "account_uid" => %{"object" => "HubIdentity.User", "uid" => "sender"},
          "description" => "depost.total",
          "kind" => "credit",
          "money" => %{"amount" => "amount", "currency" => "JPY"}
        },
        %{
          "account_uid" => %{"object" => "Bank.Cash", "uid" => "provider"},
          "description" => "depost.total",
          "kind" => "debit",
          "money" => %{"amount" => "amount", "currency" => "JPY"}
        },
        %{
          "account_uid" => %{"object" => "Bank.Cash", "uid" => "provider"},
          "description" => "depost.expense",
          "kind" => "credit",
          "money" => %{"amount" => "transaction_expense", "currency" => "JPY"}
        },
        %{
          "account_uid" => %{"object" => "Bank.Expense", "uid" => "provider"},
          "description" => "depost.expense",
          "kind" => "debit",
          "money" => %{"amount" => "transaction_expense", "currency" => "JPY"}
        }
      ]
    },
    name: "Wallet Deposit"
  },
  %{
    json_config: %{
      "entry" => %{
        "description" => %{
          "string" => "sender.deposit.reciever",
          "values" => ["sender", "reciever"]
        },
        "owner" => %{
          "object" => "TransferRequest",
          "uid" => %{"string" => "request_uid", "values" => ["request_uid"]}
        }
      },
      "transactions" => [
        %{
          "account_uid" => %{"object" => "HubIdentity.User", "uid" => "sender"},
          "description" => "sender.total",
          "kind" => "debit",
          "money" => %{"amount" => "amount", "currency" => "JPY"}
        },
        %{
          "account_uid" => %{"object" => "HubIdentity.User", "uid" => "reciever"},
          "description" => "reciever.total",
          "kind" => "credit",
          "money" => %{"amount" => "amount", "currency" => "JPY"}
        },
        %{
          "account_uid" => %{"object" => "HubIdentity.User", "uid" => "sender"},
          "description" => "transfer.fee",
          "kind" => "debit",
          "money" => %{"amount" => "transaction_fee", "currency" => "JPY"}
        },
        %{
          "account_uid" => wallet_fee.uuid,
          "description" => "transfer.fee",
          "kind" => "credit",
          "money" => %{"amount" => "transaction_fee", "currency" => "JPY"}
        }
      ]
    },
    name: "Wallet Transfer"
  },
  %{
    json_config: %{
      "entry" => %{
        "description" => %{
          "string" => "sender.payment.reciever",
          "values" => ["sender", "reciever"]
        },
        "owner" => %{
          "object" => "PaymentRequest",
          "uid" => %{"string" => "request_uid", "values" => ["request_uid"]}
        }
      },
      "transactions" => [
        %{
          "account_uid" => %{"object" => "HubIdentity.User", "uid" => "sender"},
          "description" => "sender.total",
          "kind" => "debit",
          "money" => %{"amount" => "amount", "currency" => "JPY"}
        },
        %{
          "account_uid" => %{"object" => "Hubsynch.Company", "uid" => "reciever"},
          "description" => "reciever.total",
          "kind" => "credit",
          "money" => %{"amount" => "amount", "currency" => "JPY"}
        },
        %{
          "account_uid" => wallet_fee.uuid,
          "description" => "payment.fee",
          "kind" => "credit",
          "money" => %{"amount" => "transaction_fee", "currency" => "JPY"}
        },
        %{
          "account_uid" => %{"object" => "Hubsynch.Company", "uid" => "reciever"},
          "description" => "reciever.payment.fee",
          "kind" => "debit",
          "money" => %{"amount" => "transaction_fee", "currency" => "JPY"}
        }
      ]
    },
    name: "Wallet Purchase"
  },
  %{
    json_config: %{
      "entry" => %{
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
      },
      "transactions" => [
        %{
          "account_uid" => %{
            "object" => "CreditCard.Payments",
            "uid" => "payment_company_code"
          },
          "description" => %{
            "string" => "company_app_id.total.debit",
            "values" => ["company_app_id"]
          },
          "kind" => "debit",
          "money" => %{"amount" => "payment_amount", "currency" => "JPY"}
        },
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
        %{
          "account_uid" => %{
            "object" => "Hubsynch.Company",
            "uid" => "company_app_id"
          },
          "description" => %{
            "string" => "company_app_id.transportion_expense.debit",
            "values" => ["company_app_id"]
          },
          "kind" => "debit",
          "money" => %{"amount" => "transportation_fee", "currency" => "JPY"}
        },
        %{
          "account_uid" => transport_payables.uuid,
          "description" => %{
            "string" => "company_app_id.transportion_payables.credit",
            "values" => ["company_app_id"]
          },
          "kind" => "credit",
          "money" => %{"amount" => "transportation_fee", "currency" => "JPY"}
        },
        %{
          "account_uid" => %{
            "object" => "Hubsynch.Company",
            "uid" => "company_app_id"
          },
          "description" => %{
            "string" => "company_app_id.total_fees.debit",
            "values" => ["company_app_id"]
          },
          "kind" => "debit",
          "money" => %{"amount" => "total_fees", "currency" => "JPY"}
        },
        %{
          "account_uid" => %{
            "object" => "CreditCard.Payables",
            "uid" => "payment_company_code"
          },
          "description" => %{
            "string" => "company_app_id.transaction_payables.credit",
            "values" => ["company_app_id"]
          },
          "kind" => "credit",
          "money" => %{"amount" => "commission", "currency" => "JPY"}
        },
        %{
          "account_uid" => hubsynch_fees.uuid,
          "description" => %{
            "string" => "company_app_id.hubsynch_fee.credit",
            "values" => ["company_app_id"]
          },
          "kind" => "credit",
          "money" => %{"amount" => "system_fee", "currency" => "JPY"}
        }
      ]
    },
    name: "Hubysnch payment entry"
  }
]

Enum.each(entry_builders, &HubLedger.Ledgers.create_entry_builder(&1))

hub_identity_uids = [
  "c6efc679-c2ba-473f-9b12-c0879e9805b7",
  "b44c540c-6b3d-4329-a0e6-c0fe9f8b522c"
]

for hub_identity_uid <- hub_identity_uids do
  case HubLedger.Users.get_user(%{hub_identity_uid: hub_identity_uid}) do
    nil -> HubLedger.Users.create_admin_user(%{hub_identity_uid: hub_identity_uid})
    _ -> ""
  end
end
