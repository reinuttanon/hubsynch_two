defmodule HubIdentity.HttpTester do
  # Response for google JWK certs
  def get!("https://www.googleapis.com/oauth2/v3/certs", [], hackney: [:insecure]) do
    %HTTPoison.Response{
      body:
        "{\n  \"keys\": [\n    {\n      \"kty\": \"RSA\",\n      \"kid\": \"783ec031c59e11f257d0ec15714ef607ce6a2a6f\",\n      \"use\": \"sig\",\n      \"n\": \"8Yb9hQAJroV6VKCsZZ6ylhVJqo0gsFa0Ca8ytzanKKWsCjo6RaqLjej7QKniTKwhUheCvbfLUqY9Mc6iMbA3gI-6_2lLQbbxExt6WUpf-CAEv1oUcnH_jA6X5Bdu4TdUX29s3D8J95d0eR8z8J1pe-7CjTBClx7lZd5xSRcoDXHDhzkwvc-EehYV46FsJyZCthLpAXvj81gpfycveavNFBMj-nlHKopZvhMcwbsK5JZ37wn2SxFigpfmIojheFVShJsNmLErHVC9HoHTC0iMibsKdyo7mk5QNM_rdBK-KjJhlQr8l7CktAqUJIQzkW8qC7tV7Hl0xicp6ylWZ-pj-Q\",\n      \"e\": \"AQAB\",\n      \"alg\": \"RS256\"\n    },\n    {\n      \"kty\": \"RSA\",\n      \"kid\": \"eea1b1f42807a8cc136a03a3c16d29db8296daf0\",\n      \"alg\": \"RS256\",\n      \"use\": \"sig\",\n      \"e\": \"AQAB\",\n      \"n\": \"0zNdxOgV5VIpoeAfj8TMEGRBFg-gaZWz94ePR1yxTKzScHakH4F4wcMEyL0vNE-yW_u4pOl9E-hAalPa2tFv4fCVNMMkmKwcf0gm9wNFWXGakVQ8wER4iUg33MyUGOWj2RGX1zlZxCdFoZRtshLx8xcpL3F5Hlh6m8MqIAowWtusTf5TtYMXFlPaWLQgRXvoOlLZ-muzEuutsZRu-agdOptnUiAZ74e8BgaKN8KNEZ2SqP6vE4w16mgGHQjEPUKz9exxcsnbLru6hZdTDvXbX9IduabyvHy8vQRZsqlE9lTiOOOC9jwh27TXsD05HAXmNYiR6voekzEvfS88vnot2Q\"\n    }\n  ]\n}\n",
      headers: [
        {"Date", "Thu, 21 Jan 2021 04:47:00 GMT"},
        {"Expires", "Thu, 21 Jan 2021 09:51:25 GMT"},
        {"Content-Type", "application/json; charset=UTF-8"},
        {"Vary", "X-Origin"},
        {"Vary", "Referer"},
        {"Server", "ESF"},
        {"X-XSS-Protection", "0"},
        {"X-Frame-Options", "SAMEORIGIN"},
        {"X-Content-Type-Options", "nosniff"},
        {"Cache-Control", "public, max-age=18265, must-revalidate, no-transform"},
        {"Age", "6"},
        {"Alt-Svc",
         "h3-29=\":443\"; ma=2592000,h3-T051=\":443\"; ma=2592000,h3-Q050=\":443\"; ma=2592000,h3-Q046=\":443\"; ma=2592000,h3-Q043=\":443\"; ma=2592000,quic=\":443\"; ma=2592000; v=\"46,43\""},
        {"Accept-Ranges", "none"},
        {"Vary", "Origin,Accept-Encoding"},
        {"Transfer-Encoding", "chunked"}
      ],
      request: %HTTPoison.Request{
        body: "",
        headers: [],
        method: :get,
        options: [hackney: [:insecure]],
        params: %{},
        url: "https://www.googleapis.com/oauth2/v3/certs"
      },
      request_url: "https://www.googleapis.com/oauth2/v3/certs",
      status_code: 200
    }
  end

  # GET user information with access_token from Facebook
  def get(
        <<104, 116, 116, 112, 115, 58, 47, 47, 103, 114, 97, 112, 104, 46, 102, 97, 99, 101, 98,
          111, 111, 107, 46, 99, 111, 109, 47, 118, 57, 46, 48, 47, 109, 101, _::binary>>
      ) do
    {:ok,
     %HTTPoison.Response{
       status_code: 200,
       body: "{\"email\":\"sullymustycode@gmail.com\",\"id\":\"12345\"}"
     }}
  end

  # GET for testing successful found user webhook response in ClientServices.Webhooks
  def get("www.webhook.url?email=erin@hivelocity.co.jp", [{"x-api-key", "webhook_auth_key"}]) do
    {:ok,
     %HTTPoison.Response{
       status_code: 200,
       body: "{\"owner_type\":\"HubsynchV2.User\",\"owner_uid\":\"12345\"}"
     }}
  end

  # GET for testing successful found user webhook response in ClientServices.Webhooks
  def get("www.webhook.url?email=erin123@hivelocity.co.jp", [{"x-api-key", "webhook_auth_key"}]) do
    {:ok,
     %HTTPoison.Response{
       status_code: 200,
       body: "{\"owner_type\":\"Hubsynch.User\",\"owner_uid\":38185}"
     }}
  end

  # GET www.webhook.url/error? for testing error webhook response in ClientServices.Webhooks
  def get(
        <<119, 119, 119, 46, 119, 101, 98, 104, 111, 111, 107, 46, 117, 114, 108, 47, 101, 114,
          114, 111, 114, 63, _::binary>>,
        _headers
      ) do
    {:ok,
     %HTTPoison.Response{
       status_code: 404,
       body: "not found"
     }}
  end

  # GET www.webhook.url?email=null@ for testing successful no user webhooks in ClientServices.Webhooks
  def get(
        <<119, 119, 119, 46, 119, 101, 98, 104, 111, 111, 107, 46, 117, 114, 108, 63, 101, 109,
          97, 105, 108, 61, 110, 117, 108, 108, 64, _::binary>>,
        _headers
      ) do
    {:ok,
     %HTTPoison.Response{
       status_code: 200,
       body: "\"\""
     }}
  end

  # GET www.webhook.url?email=other@ for testing successful no user webhooks in ClientServices.Webhooks
  def get(
        <<119, 119, 119, 46, 119, 101, 98, 104, 111, 111, 107, 46, 117, 114, 108, 63, 101, 109,
          97, 105, 108, 61, 111, 116, 104, 101, 114, 64, _::binary>>,
        _headers
      ) do
    {:ok,
     %HTTPoison.Response{
       status_code: 200,
       body: "{\"owner_type\":\"\",\"owner_uid\":\"\"}"
     }}
  end

  # POST to get access_token from Google
  # email: "erin@hivelocity.co.jp"
  # provider_id: "105374681595972189362"
  def post(
        <<119, 119, 119, 46, 103, 111, 111, 103, 108, 101, 46, 99, 111, 109, _::binary>>,
        "",
        _headers
      ) do
    {:ok,
     %HTTPoison.Response{
       status_code: 200,
       body:
         "{\n  \"access_token\": \"ya29.a0AfH6SMApp3QCCKyO3FFsbV030vubQA2h4Ff-2lrgt68tdP1f05SU4RwltF3Tir63yrEPPd0R_Vg0OLxLKmOr0kq1k0namPKw91108J-r4KfIgNzLAi82iNmM4w4rNZiX2ZsVOCX72LB2e1gDiHkf-_a3i9K2tsCOifR8rcxoQ-g\",\n  \"expires_in\": 3599,\n  \"scope\": \"openid https://www.googleapis.com/auth/userinfo.email\",\n  \"token_type\": \"Bearer\",\n  \"id_token\": \"#{
           erin_hivelocity
         }\"\n}"
     }}
  end

  # POST to get access_token from Facebook
  # email: "sullymustycode@gmail.com"
  # provider_id: "12345"
  def post(
        <<119, 119, 119, 46, 102, 97, 99, 101, 98, 111, 111, 107, 46, 99, 111, 109, _::binary>>,
        "",
        _headers
      ) do
    {:ok,
     %HTTPoison.Response{
       status_code: 200,
       body:
         "{\"access_token\":\"EAAjdCzU2WI8BAKOf0lgROqxPNLMfUmIrpxpiUSSe3KSJpoFZCQZBk0RMkZBOCrb61Vkb0S8W9M7UvI2GXGM4Cj0RMNwtZAGjV3t22JrompPZAk9rkZAOeiabgyhqBX76IefzRvlXOS3leNVV5KZCfP4zWlZCWEdtgixIFqvf9XIAeQZDZD\",\"token_type\":\"bearer\",\"expires_in\":5183999}"
     }}
  end

  defp sullymustycode do
    "eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlYTFiMWY0MjgwN2E4Y2MxMzZhMDNhM2MxNmQyOWRiODI5NmRhZjAiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIyMjEzMjQwMTgyMTEtdXN0Z3FuN3Vwb3JkOHJ1NXBidG5tajh1MDNkZ2Q5OTQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIyMjEzMjQwMTgyMTEtdXN0Z3FuN3Vwb3JkOHJ1NXBidG5tajh1MDNkZ2Q5OTQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDUzNzQ2ODE1OTU5NzIxODkzNjIiLCJoZCI6ImhpdmVsb2NpdHkuY28uanAiLCJlbWFpbCI6ImVyaW5AaGl2ZWxvY2l0eS5jby5qcCIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoiTDhiemNkcDVqalQyV3FMYjNicDlNUSIsImlhdCI6MTYxMTE4NjAxMSwiZXhwIjoxNjExMTg5NjExfQ.XoBCgc4o5xNPtyA2Eis34JvO7Mbvxhv8Q0khH6MecGUQS3PGFnj7SqZir55Ptce27n9sB56391ppX78nU_OK_q4xlSigXfXuN3uYg3ZSI0U-Cmh_3sd1RYLf8EuOJUDg9Tmq9a1M90Mfw65HbxaskG3Y31fAzib_dFodCv0HzDiuhJhKEPv5NFuYA0db70pNyV5c3se33_GmrnSJASa59BKVc18a9HUWm1VdKT9dFyWA5MXMBp1Hd8nxBqn5393VDYiMNtyQNloniVt-jWaVcDmsvPTAFzpj1qYX8nJfL4OPzkSt1e0-ZZsqgSoxVq1_KEKV7YIuLC7UICo0WI2jSQ"
  end

  defp erin_hivelocity do
    "eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlYTFiMWY0MjgwN2E4Y2MxMzZhMDNhM2MxNmQyOWRiODI5NmRhZjAiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIyMjEzMjQwMTgyMTEtdXN0Z3FuN3Vwb3JkOHJ1NXBidG5tajh1MDNkZ2Q5OTQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIyMjEzMjQwMTgyMTEtdXN0Z3FuN3Vwb3JkOHJ1NXBidG5tajh1MDNkZ2Q5OTQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDUzNzQ2ODE1OTU5NzIxODkzNjIiLCJoZCI6ImhpdmVsb2NpdHkuY28uanAiLCJlbWFpbCI6ImVyaW5AaGl2ZWxvY2l0eS5jby5qcCIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoiTDhiemNkcDVqalQyV3FMYjNicDlNUSIsImlhdCI6MTYxMTE4NjAxMSwiZXhwIjoxNjExMTg5NjExfQ.XoBCgc4o5xNPtyA2Eis34JvO7Mbvxhv8Q0khH6MecGUQS3PGFnj7SqZir55Ptce27n9sB56391ppX78nU_OK_q4xlSigXfXuN3uYg3ZSI0U-Cmh_3sd1RYLf8EuOJUDg9Tmq9a1M90Mfw65HbxaskG3Y31fAzib_dFodCv0HzDiuhJhKEPv5NFuYA0db70pNyV5c3se33_GmrnSJASa59BKVc18a9HUWm1VdKT9dFyWA5MXMBp1Hd8nxBqn5393VDYiMNtyQNloniVt-jWaVcDmsvPTAFzpj1qYX8nJfL4OPzkSt1e0-ZZsqgSoxVq1_KEKV7YIuLC7UICo0WI2jSQ"
  end
end
