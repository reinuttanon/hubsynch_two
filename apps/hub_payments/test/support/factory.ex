defmodule HubPayments.Factory do
  use ExMachina.Ecto, repo: HubPayments.Repo

  def atm_payment_factory do
    %HubPayments.Payments.AtmPayment{
      money: Money.new(10_000, :JPY),
      payment_detail: "Payment Detail",
      payment_detail_kana: "Payment Detail Kana",
      payment_limit_date: 20,
      reference: "some reference",
      provider: build(:provider),
      owner: %HubPayments.Embeds.Owner{
        object: "HubIdentity.User",
        uid: "user_12345678"
      },
      uuid: Ecto.UUID.generate()
    }
  end

  def charge_factory do
    %HubPayments.Payments.Charge{
      money: Money.new(10_000, :JPY),
      credit_card: build(:credit_card),
      provider: build(:provider),
      owner: %HubPayments.Embeds.Owner{
        object: "HubIdentity.User",
        uid: "user_12345678"
      },
      uuid: Ecto.UUID.generate()
    }
  end

  def credit_card_factory do
    %HubPayments.Wallets.CreditCard{
      brand: "visa",
      exp_month: "01",
      exp_year: "23",
      fingerprint: "this is a long fingerprint with a swirl",
      last_four: "4321",
      uuid: Ecto.UUID.generate(),
      wallet: build(:wallet)
    }
  end

  def message_factory do
    %HubPayments.Providers.Message{
      data: %{value: "one", payment_id: "somepayment_id"},
      type: "authorization",
      request: "<xml>these are the droids your looking for</xml>",
      provider: build(:provider),
      owner: %{object: "HubPayments.Charge", uid: Ecto.UUID.generate()}
    }
  end

  def owner_factory do
    %{
      object: "some_object",
      uid: "some_owner_uid"
    }
  end

  def payment_config_factory do
    %HubPayments.ClientServices.PaymentConfig{
      client_service_uuid: "hub_identity_client_service_uid",
      payment_methods: ["credit_card"],
      statement_name: "some statement name",
      uuid: Ecto.UUID.generate(),
      provider: build(:provider)
    }
  end

  def point_factory do
    %HubPayments.Payments.Point{
      money: Money.new(10_000, :JPY),
      uuid: Ecto.UUID.generate()
    }
  end

  def provider_factory do
    %HubPayments.Providers.Provider{
      name: "test provider",
      credentials: %{secret: "sauce", ufo: "are real"},
      url: "https://hivelocity.co.jp",
      uuid: Ecto.UUID.generate()
    }
  end

  def setting_factory do
    %HubPayments.Shared.Setting{
      active: true,
      env: "development",
      key: sequence(:key, &"a_key#{&1}"),
      type: "secret",
      value: "key_value"
    }
  end

  def wallet_factory do
    %HubPayments.Wallets.Wallet{
      owner: %HubPayments.Embeds.Owner{
        object: "HubIdentity.User",
        uid: "user_12345678"
      },
      uuid: Ecto.UUID.generate()
    }
  end
end
