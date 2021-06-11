# mix run priv/repo/transaction_data.exs
alias HubLedger.Accounts
alias HubLedger.Ledgers
alias HubLedger.Ledgers.{Entry, Transaction}

total_entries = 5000


gmo_payments = Accounts.get_account_by_owner(%{"object" => "CreditCard.Payments", "uid" => "300"})
gmo_payables = Accounts.get_account_by_owner(%{"object" => "CreditCard.Payables", "uid" => "300"})

smbc_payments = Accounts.get_account_by_owner(%{"object" => "CreditCard.Payments", "uid" => "200"})
smbc_payables = Accounts.get_account_by_owner(%{"object" => "CreditCard.Payables", "uid" => "200"})

providers = [
  %{
    payments: gmo_payments.id,
    payables: gmo_payables.id,
  },
  %{
    payments: smbc_payments.id,
    payables: smbc_payables.id,
  }
]

glay = Accounts.get_account_by_owner(%{"object" => "Hubsynch.Company", "uid" => "app_100"})
hi = Accounts.get_account_by_owner(%{"object" => "Hubsynch.Company", "uid" => "app_101"})
pizza = Accounts.get_account_by_owner(%{"object" => "Hubsynch.Company", "uid" => "app_102"})
seventeen = Accounts.get_account_by_owner(%{"object" => "Hubsynch.Company", "uid" => "app_103"})

company_apps = [
  %{account: glay.id, app_id: "app_100"},
  %{account: hi.id, app_id: "app_101"},
  %{account: pizza.id, app_id: "app_102"},
  %{account: seventeen.id, app_id: "app_103"}
]

hubsynch_fee_account = Accounts.get_account_by_owner(%{"object" => "Hubsynch.Fees", "uid" => "1"})
transportation_fee_account = Accounts.get_account_by_owner(%{"object" => "Hubsynch.Payables", "uid" => "1"})

for _ <- 0..total_entries do
  user_id = Enum.random(1000..2000)
  company_app = Enum.random(company_apps)
  use_app_transaction_id = Enum.random(1000..10_000)
  payment_amount = Enum.random(10_000..50_000)
  system_fee = 500
  commission = 200
  total_fees = 700
  transportation_fee = Enum.random(200..1000)
  provider = Enum.random(providers)
  past = Enum.random(0..-7257600)
  date = DateTime.utc_now() 
    |> DateTime.truncate(:second) 
    |> DateTime.add(past, :second)

  entry_attrs = %{
   description: "#{user_id}.purchase.#{company_app.app_id}",
   reported_date: date,
    owner: %{
      object: "UseAppTransaction", 
      uid: "#{use_app_transaction_id}"
    }
  }

  transaction_attrs = [
    %{
      account_id: provider.payments,
      description: "#{company_app.app_id}.total.debit",
      kind: "debit",
      money: %Money{amount: payment_amount, currency: :JPY},
      reported_date: date,
    },
    %{
      account_id: company_app.account,
      description: "#{company_app.app_id}.total.credit",
      kind: "credit",
      money: %Money{amount: payment_amount, currency: :JPY},
      reported_date: date,
    },
    %{
      account_id: company_app.account,
      description: "#{company_app.app_id}.transportion_expense.debit",
      kind: "debit",
      money: %Money{amount: transportation_fee, currency: :JPY},
      reported_date: date,
    },
   %{
      account_id: transportation_fee_account.id,
      description: "#{company_app.app_id}.transportion_payables.credit",
      kind: "credit",
      money: %Money{amount: transportation_fee, currency: :JPY},
      reported_date: date,
    },
    %{
      account_id: company_app.account, # Glay company App
      description: "#{company_app.app_id}.total_fees.debit",
      kind: "debit",
      money: %Money{amount: total_fees, currency: :JPY},
      reported_date: date,
    },
    %{
      account_id: provider.payables,
      description: "#{company_app.app_id}.transaction_payables.credit",
      kind: "credit",
      money: %Money{amount: commission, currency: :JPY},
      reported_date: date,
    },
    %{
      account_id: hubsynch_fee_account.id,
      description: "#{company_app.app_id}.hubsynch_fee.credit",
      kind: "credit",
      money: %Money{amount: system_fee, currency: :JPY},
      reported_date: date,
    }
  ]

  entry = Entry.create_changeset(entry_attrs)
  transactions = Enum.map(transaction_attrs, fn attrs -> Transaction.create_changeset(attrs) end)
  Ledgers.journal_entry(entry, transactions) 

end