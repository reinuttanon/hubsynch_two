defmodule HubPayments.Providers.SBPS.MessageBuilder do
  @key Application.get_env(:hub_vault, :sbps_key)
  @iv Application.get_env(:hub_vault, :sbps_iv)

  def build_authorization(%{"cc_number" => vault_record_uid} = raw_request_values) do
    # with %VaultRecord{encrypted_data: pan} <- Tokens.get_vault_record(%{uid: vault_record_uid}),
    #      request_values <- Map.replace(raw_request_values, "cc_number", pan),
    #      {new_values, sps_hashcode} <- async_values(request_values) do
    #   request_values
    #   |> replace(new_values)
    #   |> Map.put("sps_hashcode", sps_hashcode)
    #   |> body()
    # else
    #   nil -> {:error, :invalid_vault_record}
    #   _ -> {:error, :autorization_build_failure}
    # end
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

  defp body(%{"security_code" => security_code} = request_values)
       when is_binary(security_code) do
    ~s(<?xml version="1.0" encoding="Shift_JIS"?>\
<sps-api-request id="ST01-00111-101">\
<merchant_id>#{request_values["merchant_id"]}</merchant_id>\
<service_id>#{request_values["service_id"]}</service_id>\
<cust_code>#{request_values["cust_code"]}</cust_code>\
<order_id>#{request_values["order_id"]}</order_id>\
<item_id>#{request_values["item_id"]}</item_id>\
<amount>#{request_values["amount"]}</amount>\
<pay_method_info>\
<cc_number>#{request_values["cc_number"]}</cc_number>\
<cc_expiration>#{request_values["cc_expiration"]}</cc_expiration>\
<security_code>#{request_values["security_code"]}</security_code>\
</pay_method_info>\
<pay_option_manage>\
<cust_manage_flg>#{request_values["cust_manage_flg"]}</cust_manage_flg>\
<cardbrand_return_flg>#{request_values["cardbrand_return_flg"]}</cardbrand_return_flg>\
</pay_option_manage>\
<encrypted_flg>#{request_values["encrypted_flg"]}</encrypted_flg>\
<request_date>#{request_values["request_date"]}</request_date>\
<limit_second>#{request_values["limit_second"]}</limit_second>\
<sps_hashcode>#{request_values["sps_hashcode"]}</sps_hashcode>\
</sps-api-request>)
  end

  defp body(request_values) do
    ~s(<?xml version="1.0" encoding="Shift_JIS"?>\
<sps-api-request id="ST01-00111-101">\
<merchant_id>#{request_values["merchant_id"]}</merchant_id>\
<service_id>#{request_values["service_id"]}</service_id>\
<cust_code>#{request_values["cust_code"]}</cust_code>\
<order_id>#{request_values["order_id"]}</order_id>\
<item_id>#{request_values["item_id"]}</item_id>\
<amount>#{request_values["amount"]}</amount>\
<pay_method_info>\
<cc_number>#{request_values["cc_number"]}</cc_number>\
<cc_expiration>#{request_values["cc_expiration"]}</cc_expiration>\
</pay_method_info>\
<pay_option_manage>\
<cust_manage_flg>#{request_values["cust_manage_flg"]}</cust_manage_flg>\
<cardbrand_return_flg>#{request_values["cardbrand_return_flg"]}</cardbrand_return_flg>\
</pay_option_manage>\
<encrypted_flg>#{request_values["encrypted_flg"]}</encrypted_flg>\
<request_date>#{request_values["request_date"]}</request_date>\
<limit_second>#{request_values["limit_second"]}</limit_second>\
<sps_hashcode>#{request_values["sps_hashcode"]}</sps_hashcode>\
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
    do: System.get_env("SBPS_HASH_KEY") || Application.get_env(:hub_vault, :sbps_hash_key)

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
end
