defmodule HubLedger.Factory do
  use ExMachina.Ecto, repo: HubLedger.Repo

  def access_request_factory do
    %HubLedger.Users.AccessRequest{
      hub_identity_uid: "Some hub_identity_uid",
      approved_at: nil,
      approver_id: nil
    }
  end

  def account_factory do
    %HubLedger.Accounts.Account{
      active: true,
      currency: "JPY",
      name: "ErinTest",
      owner: %HubLedger.Embeds.Owner{object: "Payment", uid: "200"},
      type: "asset",
      kind: "debit",
      uuid: Ecto.UUID.generate()
    }
  end

  def balance_factory do
    %HubLedger.Accounts.Balance{
      active: true,
      money: Money.new(0, "JPY"),
      uuid: Ecto.UUID.generate(),
      account: build(:account)
    }
  end

  def entry_factory do
    %HubLedger.Ledgers.Entry{
      description: "user.give.money",
      owner: %HubLedger.Embeds.Owner{object: "HubPayment.Transfer", uid: "1234"},
      uuid: Ecto.UUID.generate()
    }
  end

  def entry_builder_factory do
    %HubLedger.Ledgers.EntryBuilder{
      active: true,
      json_config: %{},
      name: "test builder",
      uuid: Ecto.UUID.generate()
    }
  end

  def transaction_factory do
    %HubLedger.Ledgers.Transaction{
      money: Money.new(10_000, "JPY"),
      description: "pardon.bribe",
      kind: "credit",
      uuid: Ecto.UUID.generate(),
      account: build(:account),
      entry: build(:entry)
    }
  end

  def user_factory do
    %HubLedger.Users.User{
      uuid: "User uuid",
      deleted_at: nil,
      role: "user",
      hub_identity_uid: "Hub Identity uid"
    }
  end

  def wallet_asset_account_factory do
    %HubLedger.Accounts.Account{
      active: true,
      currency: "JPY",
      name: "DebitOwner",
      owner: %HubLedger.Embeds.Owner{object: "Payment", uid: "200"},
      type: "asset",
      kind: "debit",
      uuid: "asset_uid"
    }
  end

  def wallet_liability_account_factory do
    %HubLedger.Accounts.Account{
      active: true,
      currency: "JPY",
      name: "CreditOwner",
      owner: %HubLedger.Embeds.Owner{object: "Payment", uid: "200"},
      type: "liability",
      kind: "credit",
      uuid: "liability_uid"
    }
  end

  def wallet_entry_builder_factory do
    %HubLedger.Ledgers.EntryBuilder{
      active: true,
      json_config: %{
        "entry" => %{
          "description" => %{
            "string" => "sender.deposit.wallet",
            "values" => ["sender"]
          },
          "owner" => "DepositRequest",
          "uid" => "test_uid"
        },
        "transactions" => [
          %{
            "account_uid" => "liability_uid",
            "description" => "depost.total",
            "kind" => "credit",
            "money" => %{"amount" => "amount", "currency" => "JPY"}
          },
          %{
            "account_uid" => "asset_uid",
            "description" => "depost.total",
            "kind" => "debit",
            "money" => %{"amount" => "amount", "currency" => "JPY"}
          }
        ]
      },
      name: "test builder",
      uuid: Ecto.UUID.generate()
    }
  end
end
