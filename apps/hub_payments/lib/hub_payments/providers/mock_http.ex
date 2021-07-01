defmodule HubPayments.Providers.MockHttp do
  @paygent_url Application.get_env(:hub_payments, :paygent_url)
  @sbps_url Application.get_env(:hub_payments, :sbps_url)

  def post(@sbps_url, body, headers, options)
      when is_binary(body) do
    with true <- headers == sbps_headers(),
         true <- options == sbps_options() do
      simulate_sbps_response(body)
    else
      false -> {:error, "invalid sbps request"}
    end
  end

  def post(@paygent_url <> _url, "", headers, _options) do
    with true <- headers == paygent_headers() do
      {:ok, %HTTPoison.Response{status_code: 200, body: paygent_success_body()}}
    end
  end

  def post(
        "https://stage-vault.hubsynch.com/api/v1/providers/process" <> _url,
        body,
        _headers,
        _options
      ) do
    {:ok, map_body} = Jason.decode(body)

    case map_body["provider"] do
      "paygent" -> vault_paygent_response(map_body["values"]["card_number"])
      "sbps" -> vault_sbps_response(map_body["values"]["cc_number"])
    end
  end

  def post(
        @paygent_url <> _url,
        _body,
        _headers,
        _options
      ) do
    {:ok, %HTTPoison.Response{status_code: 200, body: paygent_success_body()}}
  end

  def post(_url, _body, _headers, _options), do: {:error, "bad request"}

  defp paygent_success_body do
    "\r\nresult=0\r\npayment_id=26505142\r\ntrading_id=\r\nissur_class=1\r\nacq_id=50001\r\nacq_name=NICOS\r\nissur_name=ﾋﾞｻﾞ\r\nfc_auth_umu=\r\ndaiko_code=\r\ncard_shu_code=\r\nk_card_name=\r\nissur_id=\r\nattempt_kbn=\r\nfingerprint=fvryIbkXNqjADaNqIRvpdcf5BDbhYQJhBsybDua0RGGVliC0QWHcXXTy6N7YeaUV\r\nmasked_card_number=************0000\r\ncard_valid_term=0122\r\nout_acs_html="
    |> Codepagex.from_string!("VENDORS/MICSFT/WINDOWS/CP932")
  end

  defp paygent_success_capture_body do
    "\r\nresult=0\r\npayment_id=26505142\r\ntrading_id=\r\nissur_class=1\r\nacq_id=50001\r\nacq_name=NICOS\r\nissur_name=ﾋﾞｻﾞ\r\nfc_auth_umu=\r\ndaiko_code=\r\ncard_shu_code=\r\nk_card_name=\r\nissur_id=\r\nattempt_kbn=\r\nfingerprint=fvryIbkXNqjADaNqIRvpdcf5BDbhYQJhBsybDua0RGGVliC0QWHcXXTy6N7YeaUV\r\nmasked_card_number=************0000\r\ncard_valid_term=0122\r\nout_acs_html="
  end

  defp paygent_auth_success_body do
    %{
      provider: "paygent",
      response:
        "\r\nresult=0\r\npayment_id=26505142\r\ntrading_id=\r\nissur_class=1\r\nacq_id=50001\r\nacq_name=NICOS\r\nissur_name=ﾋﾞｻﾞ\r\nfc_auth_umu=\r\ndaiko_code=\r\ncard_shu_code=\r\nk_card_name=\r\nissur_id=\r\nattempt_kbn=\r\nfingerprint=fvryIbkXNqjADaNqIRvpdcf5BDbhYQJhBsybDua0RGGVliC0QWHcXXTy6N7YeaUV\r\nmasked_card_number=************0000\r\ncard_valid_term=0122\r\nout_acs_html=",
      type: "authorization",
      uid: "vault_record_531914f6-7e21-4753-b2ee-4809a6540882"
    }
    |> Jason.encode!()
  end

  defp paygent_auth_failure_body do
    %{
      provider: "paygent",
      response:
        "\r\nresult=1\r\nresponse_code=P004\r\nresponse_detail=SomePaygentFailureMessage\r\npayment_id=\r\ntrading_id=\r\nissur_class=\r\nacq_id=\r\nacq_name=\r\nissur_name=\r\nfc_auth_umu=\r\ndaiko_code=\r\ncard_shu_code=\r\nk_card_name=\r\nshonin_no=\r\nissur_id=\r\nattempt_kbn=\r\nfingerprint=\r\nmasked_card_number=\r\ncard_valid_term=\r\nacq_member_no=\r\nout_acs_html=",
      type: "authorization",
      uid: "vault_record_531914f6-7e21-4753-b2ee-4809a6540882"
    }
    |> Jason.encode!()
  end

  defp paygent_headers do
    [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"charset", "Windows-31J"},
      {"User-Agent", "curl_php"}
    ]
  end

  defp sbps_options do
    basic_id = Application.get_env(:hub_payments, :sbps_basic_id)
    hash_key = Application.get_env(:hub_payments, :sbps_hash_key)
    [hackney: [basic_auth: {basic_id, hash_key}]]
  end

  defp simulate_sbps_response(body) do
    case body =~ "invalid_transaction_id" do
      true -> {:ok, %HTTPoison.Response{status_code: 200, body: sbps_capture_failure_body()}}
      false -> {:ok, %HTTPoison.Response{status_code: 200, body: sbps_capture_success_body()}}
    end
  end

  defp sbps_auth_success_body do
    %{
      "provider" => "sbps",
      "response" =>
        "<?xml version='1.0' encoding='Shift_JIS' ?>\n  <sps-api-response id=\"ST01-00111-101\">\n    <res_result>OK</res_result>\n    <res_sps_transaction_id>B68832001ST010011110102331019339</res_sps_transaction_id>\n    <res_tracking_id>00000631552577</res_tracking_id>\n    <res_pay_method_info>\n      <cc_company_code>dynGSg07iCM=</cc_company_code>\n      <cardbrand_code>e46R6zx8tcE=</cardbrand_code>\n      <recognized_no>oHQqpCzTtqg=</recognized_no>\n      \n    </res_pay_method_info>\n    <res_process_date>20210628161127</res_process_date>\n    <res_err_code/>\n    <res_date>20210628161127</res_date>\n  </sps-api-response>\n",
      "type" => "authorization",
      "uid" => "vault_record_7a22c6a5-ac2a-424d-92e7-74b275934346"
    }
    |> Jason.encode!()
  end

  defp sbps_auth_failure_body do
    %{
      "provider" => "sbps",
      "response" =>
        "<?xml version='1.0' encoding='Shift_JIS' ?>\n  <sps-api-response id=\"ST02-00201-101\">\n    <res_result>NG</res_result>\n    <res_err_code>10137999</res_err_code>\n    <res_date>20210628154443</res_date>\n  </sps-api-response>\n",
      "type" => "authorization",
      "uid" => "vault_record_7a22c6a5-ac2a-424d-92e7-74b275934346"
    }
    |> Jason.encode!()
  end

  defp sbps_capture_success_body do
    ~s(<?xml version="1.0" encoding="Shift_JIS"?>\
<sps-api-response id="ST02-00101-101">\
<res_result>OK</res_result>\
<res_sps_transaction_id>X1234567890123456789012345678901</res_sps_transaction_id>\
<res_process_date>20120620144317</res_process_date>\
<res_date>20120620144318</res_date>\
</sps-api-response>)
  end

  defp sbps_capture_failure_body do
    ~s(<?xml version='1.0' encoding='Shift_JIS' ?>\
    <sps-api-response id=\"ST02-00201-101\">\
      <res_result>NG</res_result>\
      <res_err_code>10137999</res_err_code>\
      <res_date>20210628154443</res_date>\
    </sps-api-response>)
  end

  defp sbps_headers do
    [
      {"Content-type", "text/xml; charset=Shift_JIS"},
      {"Pragma", "no-cache"},
      {"Cache-Control", "no-store, no-cache, must-revalidate"},
      {"Cache-Control", "post-check=0, pre-check=0"},
      {"Expires", "Thu, 01 Dec 1994 16:00:00 GMT"}
    ]
  end

  defp vault_paygent_response(card_number) do
    case card_number do
      "valid_token" ->
        {:ok, %HTTPoison.Response{status_code: 200, body: paygent_auth_success_body()}}

      "valid_card_uuid" ->
        {:ok, %HTTPoison.Response{status_code: 200, body: paygent_auth_success_body()}}

      _ ->
        {:ok, %HTTPoison.Response{status_code: 200, body: paygent_auth_failure_body()}}
    end
  end

  defp vault_sbps_response(card_number) do
    case card_number do
      "valid_token" ->
        {:ok, %HTTPoison.Response{status_code: 200, body: sbps_auth_success_body()}}

      "valid_card_uuid" ->
        {:ok, %HTTPoison.Response{status_code: 200, body: sbps_auth_success_body()}}

      _ ->
        {:ok, %HTTPoison.Response{status_code: 200, body: sbps_auth_failure_body()}}
    end
  end
end
