defmodule HubPayments.Providers.SBPS.MessageBuilder do
  alias HubPayments.Payments.Charge
  alias HubPayments.Wallets.CreditCard

  @merchant_id Application.get_env(:hub_payments, :sbps_merchant_id)
  @service_id Application.get_env(:hub_payments, :service_id)

  @key Application.get_env(:hub_payments, :sbps_key)
  @iv Application.get_env(:hub_payments, :sbps_iv)

  def build_authorization(
        %Charge{money: money, owner: %{uid: owner_uid}} = charge,
        %CreditCard{
          exp_month: exp_month,
          exp_year: exp_year
        },
        token_uid,
        cvv
      ) do
      %{
      "provider" => "sbps",
      "type" => "authorization",
      "values" => %{
        "merchant_id" => @merchant_id,
        "service_id" => @service_id,
        "cust_code" => owner_uid,
        "order_id" => charge.uuid,
        "item_id" => "15481938557120588116183836371618",
        "amount" => "#{money.amount}",
        "cc_number" => token_uid,
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

  def build_authorization(
        %Charge{money: money, owner: %{uuid: owner_uuid}} = charge,
        %CreditCard{
          vault_uuid: vault_uuid,
          exp_month: exp_month,
          exp_year: exp_year
        },
        cvv
      ) do

    %{
      "provider" => "sbps",
      "type" => "authorization",
      "values" => %{
        "merchant_id" => @merchant_id,
        "service_id" => @service_id,
        "cust_code" => owner_uuid,
        "order_id" => charge.uuid,
        "item_id" => "15481938557120588116183836371618",
        "amount" => money.amount,
        "cc_number" => vault_uuid,
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

  defp async_values(request_values) do
    encrypt_task = Task.async(fn -> encrypt_values(request_values) end)
    hash_task = Task.async(fn -> generate_hash(request_values) end)

    {Task.await(encrypt_task), Task.await(hash_task)}
  end

  defp block_pad(value) do
    padding =
      value
      |> String.length()
      |> spaces()

    String.pad_trailing(value, padding)
  end

  # cust_code = user_id
  # order_id = charge_id
  # item_id = id of the product that was paid

  #   defp body()
  #        when is_binary(security_code) do
  #     ~s(<?xml version="1.0" encoding="Shift_JIS"?>\
  # <sps-api-request id="ST01-00111-101">\
  # <merchant_id>#{request_values["merchant_id"]}</merchant_id>\
  # <service_id>#{request_values["service_id"]}</service_id>\
  # <cust_code>#{request_values["cust_code"]}</cust_code>\
  # <order_id>#{request_values["order_id"]}</order_id>\
  # <item_id>#{request_values["item_id"]}</item_id>\
  # <amount>#{request_values["amount"]}</amount>\
  # <pay_method_info>\
  # <cc_number>#{request_values["cc_number"]}</cc_number>\
  # <cc_expiration>#{request_values["cc_expiration"]}</cc_expiration>\
  # <security_code>#{request_values["security_code"]}</security_code>\
  # </pay_method_info>\
  # <pay_option_manage>\
  # <cust_manage_flg>#{request_values["cust_manage_flg"]}</cust_manage_flg>\
  # <cardbrand_return_flg>#{request_values["cardbrand_return_flg"]}</cardbrand_return_flg>\
  # </pay_option_manage>\
  # <encrypted_flg>#{request_values["encrypted_flg"]}</encrypted_flg>\
  # <request_date>#{request_values["request_date"]}</request_date>\
  # <limit_second>#{request_values["limit_second"]}</limit_second>\
  # <sps_hashcode>#{request_values["sps_hashcode"]}</sps_hashcode>\
  # </sps-api-request>)
  #   end

  defp body(request_values) do
    ~s(<?xml version="1.0" encoding="Shift_JIS"?>\
    <sps-api-request id=" ST02-00201-101">
    <merchant_id>99999</merchant_id>
    <service_id>999</service_id>
    <sps_transaction_id>12345678901234567890123456789012</sps_transaction_id>
    <tracking_id>12345678901234</tracking_id>
    <processing_datetime>20071225190000</processing_datetime>
    <pay_option_manage>
      <amount>5000</amount>
    </pay_option_manage>
    <request_date>20080101235959</request_date>
    <limit_second>600</limit_second>
    <sps_hashcode>70352f41061eda4ff3c322094af068ba70c3b38b</sps_hashcode>
    </sps-api-request>)
  end

  defp encrypt_encode(nil), do: nil

  defp encrypt_encode(""), do: ""

  defp encrypt_encode(value) do
    data = block_pad(value)

    :crypto.crypto_one_time(:des_ede3_cbc, @key, @iv, data, true)
    |> Base.encode64()
  end

  defp encrypt_values(%{
         "cc_number" => cc_number,
         "cc_expiration" => expiration,
         "security_code" => security_code
       }) do
    cc_number_task = Task.async(fn -> encrypt_encode(cc_number) end)
    cc_expiration_task = Task.async(fn -> encrypt_encode(expiration) end)
    security_code_task = Task.async(fn -> encrypt_encode(security_code) end)

    {Task.await(cc_number_task), Task.await(cc_expiration_task), Task.await(security_code_task)}
  end

  defp encrypt_values(%{
         "cc_number" => cc_number,
         "cc_expiration" => expiration
       }) do
    cc_number_task = Task.async(fn -> encrypt_encode(cc_number) end)
    cc_expiration_task = Task.async(fn -> encrypt_encode(expiration) end)

    {Task.await(cc_number_task), Task.await(cc_expiration_task), nil}
  end

  defp generate_hash(request_values) do
    data = message_values(request_values)

    :crypto.hash(:sha, data)
    |> Base.encode16()
    |> String.downcase()
  end

  defp hash_key,
    do: System.get_env("SBPS_HASH_KEY") || Application.get_env(:hub_payments, :sbps_hash_key)

  defp message_values(%{"security_code" => security_code} = request_values)
       when is_binary(security_code) do
    request_values["merchant_id"] <>
      request_values["service_id"] <>
      request_values["cust_code"] <>
      request_values["order_id"] <>
      request_values["item_id"] <>
      request_values["amount"] <>
      request_values["cc_number"] <>
      request_values["cc_expiration"] <>
      request_values["security_code"] <>
      request_values["cust_manage_flg"] <>
      request_values["cardbrand_return_flg"] <>
      request_values["encrypted_flg"] <>
      request_values["request_date"] <>
      request_values["limit_second"] <>
      hash_key()
  end

  defp message_values(request_values) do
    request_values["merchant_id"] <>
      request_values["service_id"] <>
      request_values["cust_code"] <>
      request_values["order_id"] <>
      request_values["item_id"] <>
      request_values["amount"] <>
      request_values["cc_number"] <>
      request_values["cc_expiration"] <>
      request_values["cust_manage_flg"] <>
      request_values["cardbrand_return_flg"] <>
      request_values["encrypted_flg"] <>
      request_values["request_date"] <>
      request_values["limit_second"] <>
      hash_key()
  end

  defp replace(request_values, {cc_number, cc_expiration, nil}) do
    request_values
    |> Map.replace("cc_number", cc_number)
    |> Map.replace("cc_expiration", cc_expiration)
  end

  defp replace(request_values, {cc_number, cc_expiration, security_code})
       when is_binary(security_code) do
    request_values
    |> Map.replace("cc_number", cc_number)
    |> Map.replace("cc_expiration", cc_expiration)
    |> Map.replace("security_code", security_code)
  end

  defp spaces(value) when value <= 8, do: 8

  defp spaces(value) do
    8 - rem(value + 8, 8)
  end

  defp build_current_date do
    {{year, month, day}, {hour, minute, second}} = :calendar.local_time()
    "#{year}" <> get_last_two_num(month) <> get_last_two_num(day) <> get_last_two_num(hour) <> get_last_two_num(minute) <> get_last_two_num(second)
  end
  defp get_last_two_num(value) do
    String.slice("0#{value}", -2..-1)
  end
end
