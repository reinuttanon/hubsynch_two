defmodule HubPayments.Providers.MockHttp do
  def post("https://stbfep.sps-system.com/api/xmlapi.do", body, headers, options)
      when is_binary(body) do
    with true <- headers == sbps_headers(),
         true <- options == sbps_options() do
      {:ok, %HTTPoison.Response{status_code: 200, body: sbps_success_body()}}
    else
      false -> {:error, "invalid sbps request"}
    end
  end

  def post("https://sandbox.paygent.co.jp/n/card/request" <> _url, "", headers, _options) do
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

    case map_body["values"]["card_number"] do
      "valid_token" ->
        {:ok, %HTTPoison.Response{status_code: 200, body: vault_success_body()}}

      "valid_card_uuid" ->
        {:ok, %HTTPoison.Response{status_code: 200, body: vault_success_body()}}

      _ ->
        {:ok, %HTTPoison.Response{status_code: 200, body: vault_failure_body()}}
    end
  end

  def post(
        "https://sandbox.paygent.co.jp/n/card/request" <> _url,
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

  defp vault_success_body do
    %{
      provider: "paygent",
      response:
        "\r\nresult=0\r\npayment_id=26505142\r\ntrading_id=\r\nissur_class=1\r\nacq_id=50001\r\nacq_name=NICOS\r\nissur_name=ﾋﾞｻﾞ\r\nfc_auth_umu=\r\ndaiko_code=\r\ncard_shu_code=\r\nk_card_name=\r\nissur_id=\r\nattempt_kbn=\r\nfingerprint=fvryIbkXNqjADaNqIRvpdcf5BDbhYQJhBsybDua0RGGVliC0QWHcXXTy6N7YeaUV\r\nmasked_card_number=************0000\r\ncard_valid_term=0122\r\nout_acs_html=",
      type: "authorization",
      uid: "vault_record_531914f6-7e21-4753-b2ee-4809a6540882"
    }
    |> Jason.encode!()
  end

  defp vault_failure_body do
    %{
      provider: "paygent",
      response:
        "\r\nresult=1\r\npayment_id=\r\ntrading_id=\r\nissur_class=1\r\nacq_id=50001\r\nacq_name=NICOS\r\nissur_name=ﾋﾞｻﾞ\r\nfc_auth_umu=\r\ndaiko_code=\r\ncard_shu_code=\r\nk_card_name=\r\nissur_id=\r\nattempt_kbn=\r\nfingerprint=fvryIbkXNqjADaNqIRvpdcf5BDbhYQJhBsybDua0RGGVliC0QWHcXXTy6N7YeaUV\r\nmasked_card_number=************0000\r\ncard_valid_term=0122\r\nout_acs_html=",
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
    basic_id = Application.get_env(:hub_vault, :sbps_basic_id)
    hash_key = Application.get_env(:hub_vault, :sbps_hash_key)
    [hackney: [basic_auth: {basic_id, hash_key}]]
  end

  defp sbps_success_body do
    ~s(<?xml version="1.0" encoding="Shift_JIS"?>\
<sps-api-response id="ST02-00101-101">\
<res_result>OK</res_result>\
<res_sps_transaction_id>X1234567890123456789012345678901</res_sps_transaction_id>\
<res_process_date>20120620144317</res_process_date>\
<res_date>20120620144318</res_date>\
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
end
