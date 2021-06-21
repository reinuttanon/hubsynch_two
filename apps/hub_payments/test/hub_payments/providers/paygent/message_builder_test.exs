defmodule HubPayments.Providers.Paygent.MessageBuilderTest do
  use HubPayments.DataCase

  import HubPayments.Factory

  alias HubPayments.Providers.Paygent.MessageBuilder

  describe "build_authorization/2" do
    test "returns jason message using card uid with valid Charge and CreditCard" do
      charge = insert(:charge)
      credit_card = insert(:credit_card)

      {:ok, message} = MessageBuilder.build_authorization(charge, credit_card)

      assert message ==
               "{\"provider\":\"paygent\",\"type\":\"authorization\",\"values\":{\"3dsecure_ryaku\":\"1\",\"card_number\":\"#{
                 credit_card.uuid
               }\",\"card_valid_term\":\"#{credit_card.exp_month <> credit_card.exp_year}\",\"connect_id\":\"hivelocity2test\",\"connect_password\":\"2jjK9F2ast4NkBHS\",\"merchant_id\":\"21220\",\"payment_amount\":#{
                 charge.money.amount
               },\"payment_class\":\"10\",\"telegram_kind\":\"020\",\"telegram_version\":\"1.0\"}}"
    end

    test "returns error with invalid value" do
      {:error, message} = MessageBuilder.build_authorization("charge", "credit_card")
      assert message == "Invalid charge values"
    end
  end

  describe "build_authorization/3" do
    test "returns jason message using token uid with valid Charge and CreditCard" do
      charge = insert(:charge)
      credit_card = insert(:credit_card)

      {:ok, message} = MessageBuilder.build_authorization(charge, credit_card, "token_uid")

      assert message ==
               "{\"provider\":\"paygent\",\"type\":\"authorization\",\"values\":{\"3dsecure_ryaku\":\"1\",\"card_number\":\"token_uid\",\"card_valid_term\":\"#{
                 credit_card.exp_month <> credit_card.exp_year
               }\",\"connect_id\":\"hivelocity2test\",\"connect_password\":\"2jjK9F2ast4NkBHS\",\"merchant_id\":\"21220\",\"payment_amount\":#{
                 charge.money.amount
               },\"payment_class\":\"10\",\"telegram_kind\":\"020\",\"telegram_version\":\"1.0\"}}"
    end

    test "returns error with invalid value" do
      {:error, message} = MessageBuilder.build_authorization("charge", "credit_card", "any_Value")
      assert message == "Invalid charge values"
    end
  end

  describe "build_capture/2" do
    test "returns jason message using token uid with valid Charge and CreditCard" do
      charge = insert(:charge)
      message = insert(:message)

      {:ok, result} = MessageBuilder.build_capture(charge, message)

      assert result ==
               "merchant_id=21220&connect_id=hivelocity2test&connect_password=2jjK9F2ast4NkBHS&telegram_kind=022&telegram_version=1.0&payment_amount=#{
                 charge.money.amount
               }&payment_id=#{message.data.payment_id}"
    end

    test "returns error with invalid value" do
      {:error, message} = MessageBuilder.build_capture("charge", "message")
      assert message == "Invalid charge values"
    end
  end
end
