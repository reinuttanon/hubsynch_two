defmodule HubPayments.Factory do
  use ExMachina.Ecto, repo: HubPayments.Repo

  def provider_factory do
    %HubPayments.Providers.Provider{
      name: "test provider",
      credentials: %{secret: "sauce", ufo: "are real"},
      url: "https://hivelocity.co.jp",
      uuid: Ecto.UUID.generate()
    }
  end

  def charge_factory do
    %HubPayments.Payments.Charge{
      money: Money.new(10_000, :JPY),
      credit_card: build(:credit_card),
      provider: build(:provider)
    }
  end

  def credit_card_factory do
    %HubPayments.Wallets.CreditCard{
      brand: "visa",
      exp_month: "01",
      exp_year: "2023",
      fingerprint: "this is a long fingerprint with a swirl",
      last_four: "4321",
      uuid: Ecto.UUID.generate()
    }
  end

  def point_factory do
    %HubPayments.Payments.Point{
      money: Money.new(10_000, :JPY)
    }
  end
end
