defmodule HubPayments.Providers.Vault do
  alias HubPayments.Providers

  @http Application.get_env(:hub_payments, :http_module)
  @url "https://stage-vault.hubsynch.com/api/v1/providers/process"
  @vault_api_key "x6669hwJUcPDv28gDDYoQb9lxv4Cwb4XY12X5isI7ker31N4eYoBY3pUTdJtZX9z"

  def authorize(message, "paygent") do
    encoded = Jason.encode!(message)

    @url
    |> @http.post(encoded, headers(), [])
    |> Providers.Paygent.ResponseParser.parse_response()
  end

  defp headers do
    [
      {"x-api-key", @vault_api_key},
      {"Content-Type", "application/json"}
    ]
  end

  # def authorize(message, provider) do
  #   case Application.get_env(:hub_payments, :http_module) do
  #   end
  # end
end

# request example

# {
#   "provider": "sbps",
#   "type": "authorization",
#   "values": {
#     "merchant_id": "68832",
#     "service_id": "001",
#     "cust_code": "carrier_827617915332779141618383637161838363716201",
#     "order_id": "2358841788638747981618383637161",
#     "item_id": "15481938557120588116183836371618",
#     "amount": "1",
#     "cc_number": "03432e4f-54fd-4404-b47e-b616dd2c1fd6", //Can be token_uid or vault_record_uid
#     "cc_expiration": "203002",
#     "security_code": "123",
#     "cust_manage_flg": "1",
#     "cardbrand_return_flg": "1",
#     "encrypted_flg": "1",
#     "request_date": "20210610180037", // "string size of 12"
#     "limit_second": "600"
#   }
# }
