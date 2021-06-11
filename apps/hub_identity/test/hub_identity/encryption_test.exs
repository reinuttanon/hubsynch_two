defmodule HubIdentity.EncryptionTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Encryption

  describe "current_kids/0" do
    test "returns the current jwt keys" do
      kids = Encryption.current_kids()
      assert length(kids) == 2

      for kid <- kids do
        assert %JOSE.JWK{} = Encryption.private_key(kid)
        assert %JOSE.JWK{} = Encryption.public_key(kid)
      end
    end
  end

  describe "current_private_key/0" do
    test "returns the private key with the longest expiration" do
      sorted_expired_dates =
        Encryption.public_keys()
        |> Enum.map(fn %{expires: expires} -> expires end)
        |> Enum.sort(&(&1 >= &2))

      private_key = Encryption.current_private_key()

      assert hd(sorted_expired_dates) == private_key.expires
    end
  end

  describe "generate_tokens/2" do
    test "returns an access token and refesh token for a client service with refresh_token true" do
      client_service = insert(:client_service, refresh_token: true)
      user = insert(:user)
      email = insert(:email, user: user, primary: true)

      assert {{:ok, access_token, access_claims}, {:ok, refresh_token, refresh_claims}} =
               Encryption.generate_tokens(client_service, user, email)

      assert access_token != nil
      assert access_claims["aud"] == client_service.url
      assert access_claims["email"] == email.address
      assert access_claims["sub"] == "Identities.User:#{user.uid}"
      assert access_claims["typ"] == "access"

      assert refresh_token != nil
      assert refresh_claims["aud"] == client_service.url
      assert refresh_claims["sub"] == "Identities.User:#{user.uid}"
      assert refresh_claims["typ"] == "refresh"
    end

    test "returns only access token for client_service with refresh_token false" do
      client_service = insert(:client_service, refresh_token: false)
      user = insert(:user)
      email = insert(:email, user: user, primary: true)

      assert {:ok, access_token, access_claims} =
               Encryption.generate_tokens(client_service, user, email)

      assert access_token != nil
      assert access_claims["aud"] == client_service.url
      assert access_claims["email"] == email.address
      assert access_claims["sub"] == "Identities.User:#{user.uid}"
      assert access_claims["typ"] == "access"
    end
  end

  describe "private_key/1" do
    test "returns the private key with the matching kid" do
      kid = Encryption.current_kids() |> hd()
      private_key = Encryption.private_key(kid)
      assert private_key.fields["kid"] == kid
    end
  end

  describe "public_key/1" do
    test "returns the public key with the matching kid" do
      kid = Encryption.current_kids() |> hd()
      public_key = Encryption.public_key(kid)
      assert public_key.fields["kid"] == kid
    end
  end

  describe "public_keys/0" do
    test "returns a list of public keys formatted" do
      all_kids = Encryption.current_kids()

      public_keys = Encryption.public_keys()

      assert length(public_keys) == 2

      for kid <- all_kids do
        assert Enum.any?(public_keys, fn key -> key.kid == kid end)
      end
    end
  end

  describe "refresh_token_exchange/1" do
    test "returns an access token and claims" do
      user = insert(:user)
      client_service = insert(:client_service)
      assert {:ok, refresh_token, _} = Encryption.Tokens.refresh_token(client_service, user)

      assert {:ok, access_token, claims} = Encryption.refresh_token_exchange(refresh_token)
      assert access_token != nil
      assert claims["sub"] == "Identities.User:#{user.uid}"
      assert claims["typ"] == "access"
    end
  end

  describe "rotate_key/1" do
    test "deletes the key and updates with a new key" do
      rotate_kid = Encryption.current_kids() |> hd()
      assert {:ok, "#{rotate_kid} rotated"} == Encryption.rotate_key(rotate_kid)

      new_keys = Encryption.current_kids()
      assert length(new_keys) == 2
      refute Enum.member?(new_keys, rotate_kid)

      assert nil == Encryption.private_key(rotate_kid)
    end
  end
end
