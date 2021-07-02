defmodule HubPayments.Providers.Paygent.MessageBuilder do
  alias HubPayments.Payments.{AtmPayment, Charge}
  alias HubPayments.Providers.Message
  alias HubPayments.Wallets.CreditCard

  @merchant_id Application.get_env(:hub_payments, :paygent_merchant_id)
  @connect_id Application.get_env(:hub_payments, :connect_id)
  @connect_password Application.get_env(:hub_payments, :connect_password)

  def build_authorization(
        %Charge{money: money},
        %CreditCard{
          vault_uuid: vault_uuid,
          exp_month: exp_month,
          exp_year: exp_year
        },
        nil
      )
      when is_binary(vault_uuid) do
    %{
      "provider" => "paygent",
      "type" => "authorization",
      "values" => %{
        "merchant_id" => @merchant_id,
        "connect_id" => @connect_id,
        "connect_password" => @connect_password,
        "telegram_kind" => "020",
        "telegram_version" => "1.0",
        "payment_amount" => money.amount,
        "card_number" => vault_uuid,
        "card_valid_term" => exp_month <> exp_year,
        "payment_class" => "10",
        "3dsecure_ryaku" => "1"
      }
    }
  end

  def build_authorization(
        %Charge{money: money},
        %CreditCard{
          exp_month: exp_month,
          exp_year: exp_year
        },
        token_uuid
      )
      when is_binary(token_uuid) do
    %{
      "provider" => "paygent",
      "type" => "authorization",
      "values" => %{
        "merchant_id" => @merchant_id,
        "connect_id" => @connect_id,
        "connect_password" => @connect_password,
        "telegram_kind" => "020",
        "telegram_version" => "1.0",
        "payment_amount" => money.amount,
        "card_number" => token_uuid,
        "card_valid_term" => exp_month <> exp_year,
        "payment_class" => "10",
        "3dsecure_ryaku" => "1"
      }
    }
  end

  def build_authorization(_, _, nil), do: {:error, "Token should not be nil"}

  def build_authorization(_, _, _), do: {:error, "Invalid charge values"}

  def build_capture(%Charge{money: money}, %Message{data: data}) do
    request_values = [
      {"merchant_id", @merchant_id},
      {"connect_id", @connect_id},
      {"connect_password", @connect_password},
      {"telegram_kind", "022"},
      {"telegram_version", "1.0"},
      {"payment_amount", money.amount},
      {"payment_id", data[:payment_id]}
    ]

    {:ok, url_encode(request_values)}
  end

  def build_capture(_, _), do: {:error, "Invalid charge values"}

  def build_atm_payment(%AtmPayment{money: money} = atm_payment) do
    request_values = [
      {"merchant_id", @merchant_id},
      {"connect_id", @connect_id},
      {"connect_password", @connect_password},
      {"telegram_kind", "010"},
      {"telegram_version", "1.0"},
      {"payment_amount", money.amount},
      {"payment_detail", atm_payment.payment_detail},
      {"payment_detail_kana", atm_payment.payment_detail_kana},
      {"payment_limit_date", atm_payment.payment_limit_date}
    ]

    {:ok, url_encode(request_values)}
  end

  defp url_encode(values, encoded \\ "")

  defp url_encode([], encoded), do: encoded

  defp url_encode([{key, value} | values], "") do
    url_encode(values, "#{key}=#{value}")
  end

  defp url_encode([{key, value} | values], encoded) do
    url_encode(values, "#{encoded}&#{key}=#{value}")
  end
end
