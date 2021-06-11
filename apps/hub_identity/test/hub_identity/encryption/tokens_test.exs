defmodule HubIdentity.TokensTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Encryption.Tokens

  describe "access_token/2" do
    setup [:create_client_service]

    test "returns access token with all the claims for a user", %{client_service: client_service} do
      user = insert(:user)
      email = insert(:email, user: user, primary: true)
      assert {:ok, token, claims} = Tokens.access_token(client_service, user, email)
      assert claims["email"] == email.address
      assert claims["uid"] == user.uid

      [_header, url_encoded_jason, _signature] = String.split(token, ".")
      token_claims = Base.url_decode64!(url_encoded_jason, padding: false) |> Jason.decode!()
      assert token_claims["email"] == email.address
      assert token_claims["uid"] == user.uid
      assert token_claims["sub"] == "Identities.User:#{user.uid}"
    end
  end

  describe "refresh_token/2" do
    setup [:create_client_service]

    test "returns proper claims from the ClientService", %{client_service: client_service} do
      user = insert(:user)
      assert {:ok, token, claims} = Tokens.refresh_token(client_service, user)
      assert claims["aud"] == client_service.url
      assert claims["typ"] == "refresh"

      [_header, url_encoded_jason, _signature] = String.split(token, ".")
      token_claims = Base.url_decode64!(url_encoded_jason, padding: false) |> Jason.decode!()
      assert token_claims["aud"] == client_service.url
      assert token_claims["typ"] == "refresh"
    end
  end

  describe "refresh_exchange/1" do
    test "with valid refresh_token returns an access token" do
      user = insert(:user)
      client_service = insert(:client_service)
      assert {:ok, token, claims} = Tokens.refresh_token(client_service, user)
      [enc_header, _claims, _signature] = String.split(token, ".")
      header = Base.url_decode64!(enc_header, padding: false) |> Jason.decode!()
      assert header["kid"] != nil

      {:ok, {refresh_token, refresh_claims}, {access_token, access_claims}} =
        Tokens.refresh_exchange(token)

      [enc_access_header, _claims, _signature] = String.split(access_token, ".")
      access_header = Base.url_decode64!(enc_access_header, padding: false) |> Jason.decode!()

      assert access_header["alg"] == header["alg"]
      assert access_header["typ"] == header["typ"]
      assert access_header["kid"] != nil

      assert claims == refresh_claims
      assert refresh_token == token
      assert access_token != nil
      assert access_claims["sub"] == "Identities.User:#{user.uid}"
      assert access_claims["typ"] == "access"
    end

    test "with invalid token returns error" do
      token =
        "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodWJfaWRlbnRpdHkiLCJleHAiOjE2MDk4MjY0NjMsImlhdCI6MTYwOTc0MDA2MywiaXNzIjoiaHViX2lkZW50aXR5IiwianRpIjoiNjRhNjM1MDItYTE1Ni00MDhlLTk2MmYtOWZiODgxMmVmNzliIiwibmJmIjoxNjA5NzQwMDYyLCJzdWIiOiJVc2Vycy5Vc2VyOjJjODUyYjNhLTM3MDktNGY4MS04NjA3LWU3NGFhZTQyNmM1NCIsInR5cCI6ImFjY2VzcyJ9.YkG-4ZXEzCZCGmRL0VPI-Bu1DY8_6shXfeNEnSAx0M77gpZHUZyO4E30JtLoiN_PdRdzBDf6JSaQRZr3xtaEmQ"

      assert {:error, :bad_refresh_token} = Tokens.refresh_exchange(token)
    end
  end

  defp create_client_service(_) do
    client_service = insert(:client_service)
    %{client_service: client_service}
  end
end
