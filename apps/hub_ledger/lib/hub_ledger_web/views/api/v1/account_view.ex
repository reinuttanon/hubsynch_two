defmodule HubLedgerWeb.Api.V1.AccountView do
  use HubLedgerWeb, :view

  def render("show.json", %{uuid: uuid}) do
    %{
      Object: "account",
      uuid: uuid
    }
  end

  def render("balance.json", %{amount: amount, currency: currency, uuid: uuid}) do
    %{
      Object: "Account.Balance",
      money: %{
        amount: amount,
        currency: currency
      },
      uuid: uuid
    }
  end

  def render("running_balance.json", %{kind: kind, amount: amount, currency: currency, uuid: uuid}) do
    %{
      Object: "Balance",
      kind: kind,
      money: %{
        amount: amount,
        currency: currency
      },
      uuid: uuid
    }
  end
end
