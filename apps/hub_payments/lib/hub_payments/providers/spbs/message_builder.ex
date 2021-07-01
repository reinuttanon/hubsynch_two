defmodule HubPayments.Providers.SBPS.MessageBuilder do
  alias HubPayments.Payments.Charge
  alias HubPayments.Providers.Message
  alias HubPayments.Wallets.CreditCard

  @merchant_id Application.get_env(:hub_payments, :sbps_merchant_id)
  @service_id Application.get_env(:hub_payments, :service_id)
  @hash_key System.get_env("SBPS_HASH_KEY") || Application.get_env(:hub_payments, :sbps_hash_key)

  def build_authorization(
        %Charge{money: money} = charge,
        %CreditCard{
          vault_uuid: vault_uuid,
          exp_month: exp_month,
          exp_year: exp_year
        },
        nil
      )
      when is_binary(vault_uuid) do
    %{
      "provider" => "sbps",
      "type" => "authorization",
      "values" => %{
        "merchant_id" => @merchant_id,
        "service_id" => @service_id,
        "cust_code" => charge.owner.uid,
        "order_id" => charge.uuid,
        "item_id" => "sbps_payment",
        "amount" => "#{money.amount}",
        "cc_number" => vault_uuid,
        "cc_expiration" => "20" <> exp_year <> exp_month,
        "cust_manage_flg" => "1",
        "cardbrand_return_flg" => "1",
        "encrypted_flg" => "1",
        "request_date" => build_current_date(),
        "limit_second" => "600"
      }
    }
  end

  def build_authorization(
        %Charge{money: money} = charge,
        %CreditCard{
          exp_month: exp_month,
          exp_year: exp_year,
          cvv: cvv
        },
        token_uuid
      )
      when is_binary(token_uuid) do
    %{
      "provider" => "sbps",
      "type" => "authorization",
      "values" => %{
        "merchant_id" => @merchant_id,
        "service_id" => @service_id,
        "cust_code" => charge.owner.uid,
        "order_id" => charge.uuid,
        "item_id" => "sbps_payment",
        "amount" => "#{money.amount}",
        "cc_number" => token_uuid,
        "cc_expiration" => "20" <> exp_year <> exp_month,
        "security_code" => cvv,
        "cust_manage_flg" => "1",
        "cardbrand_return_flg" => "1",
        "encrypted_flg" => "1",
        "request_date" => build_current_date(),
        "limit_second" => "600"
      }
    }
  end

  def build_capture(%Message{data: data}) do
    request_values = %{
      "merchant_id" => @merchant_id,
      "service_id" => @service_id,
      "sps_transaction_id" => data[:sps_transaction_id],
      "tracking_id" => data[:tracking_id],
      "processing_datetime" => data[:processing_datetime],
      "request_date" => build_current_date(),
      "limit_second" => "600"
    }

    data = capture_message_values(request_values)

    sps_hashcode = generate_hash(data)

    body =
      request_values
      |> Map.put("sps_hashcode", sps_hashcode)
      |> capture_body()

    {:ok, body}
  end

  # cust_code = user_id
  # order_id = charge_id
  # item_id = id of the product that was paid

  defp capture_body(request_values) do
    ~s(<?xml version="1.0" encoding="Shift_JIS"?>\
    <sps-api-request id="ST02-00101-101">
    <merchant_id>#{request_values["merchant_id"]}</merchant_id>
    <service_id>#{request_values["service_id"]}</service_id>
    <sps_transaction_id>#{request_values["sps_transaction_id"]}</sps_transaction_id>
    <tracking_id>#{request_values["tracking_id"]}</tracking_id>
    <processing_datetime>#{request_values["processing_datetime"]}</processing_datetime>
    <request_date>#{request_values["request_date"]}</request_date>
    <limit_second>#{request_values["limit_second"]}</limit_second>
    <sps_hashcode>#{request_values["sps_hashcode"]}</sps_hashcode>
    </sps-api-request>)
  end

  defp generate_hash(data) do
    :crypto.hash(:sha, data)
    |> Base.encode16()
    |> String.downcase()
  end

  defp capture_message_values(request_values) do
    request_values["merchant_id"] <>
      request_values["service_id"] <>
      request_values["sps_transaction_id"] <>
      request_values["tracking_id"] <>
      request_values["processing_datetime"] <>
      request_values["request_date"] <> request_values["limit_second"] <> @hash_key
  end

  # Since Elixir only ships with UTC support we need to add 9 hours for Japan.
  defp build_current_date do
    %DateTime{year: year, month: month, day: day, hour: hour, minute: minute, second: second} =
      DateTime.utc_now() |> DateTime.add(32400, :second)

    "#{year}" <>
      get_last_two_num(month) <>
      get_last_two_num(day) <>
      get_last_two_num(hour) <> get_last_two_num(minute) <> get_last_two_num(second)
  end

  defp get_last_two_num(value) do
    String.slice("0#{value}", -2..-1)
  end
end
