defmodule HubIdentity.HubsynchV2.GoogleTest do
  use HubIdentity.DataCase

  alias HubIdentity.Providers.Google

  describe "parse_tokens" do
    test "returns ok and identity_params when sucessful" do
      {:ok, identity_params} = Google.parse_tokens(%{"id_token" => token()}, 123)

      assert identity_params.email == "erin@hivelocity.co.jp"
      assert identity_params.email_verified
      assert identity_params.details["email"] == "erin@hivelocity.co.jp"
      assert identity_params.provider_config_id == 123
      assert identity_params.provider == "google"
      assert identity_params.reference == "105374681595972189362"
    end
  end

  defp token do
    "eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlYTFiMWY0MjgwN2E4Y2MxMzZhMDNhM2MxNmQyOWRiODI5NmRhZjAiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIyMjEzMjQwMTgyMTEtdXN0Z3FuN3Vwb3JkOHJ1NXBidG5tajh1MDNkZ2Q5OTQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIyMjEzMjQwMTgyMTEtdXN0Z3FuN3Vwb3JkOHJ1NXBidG5tajh1MDNkZ2Q5OTQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDUzNzQ2ODE1OTU5NzIxODkzNjIiLCJoZCI6ImhpdmVsb2NpdHkuY28uanAiLCJlbWFpbCI6ImVyaW5AaGl2ZWxvY2l0eS5jby5qcCIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoiTDhiemNkcDVqalQyV3FMYjNicDlNUSIsImlhdCI6MTYxMTE4NjAxMSwiZXhwIjoxNjExMTg5NjExfQ.XoBCgc4o5xNPtyA2Eis34JvO7Mbvxhv8Q0khH6MecGUQS3PGFnj7SqZir55Ptce27n9sB56391ppX78nU_OK_q4xlSigXfXuN3uYg3ZSI0U-Cmh_3sd1RYLf8EuOJUDg9Tmq9a1M90Mfw65HbxaskG3Y31fAzib_dFodCv0HzDiuhJhKEPv5NFuYA0db70pNyV5c3se33_GmrnSJASa59BKVc18a9HUWm1VdKT9dFyWA5MXMBp1Hd8nxBqn5393VDYiMNtyQNloniVt-jWaVcDmsvPTAFzpj1qYX8nJfL4OPzkSt1e0-ZZsqgSoxVq1_KEKV7YIuLC7UICo0WI2jSQ"
  end
end
