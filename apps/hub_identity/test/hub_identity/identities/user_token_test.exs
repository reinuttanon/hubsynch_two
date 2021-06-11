defmodule HubIdentity.Identities.UserTokenTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Identities.UserToken

  describe "build_email_token/3" do
    test "returns a valid token struct and hashed token" do
      client_service = insert(:client_service)

      {token, user_token} =
        UserToken.build_email_token("email@gmail.com", "confirm", client_service.id, nil)

      assert token != user_token.token
      assert user_token.context == "confirm"
      assert user_token.sent_to == "email@gmail.com"
      assert user_token.user_id == nil
      assert user_token.client_service_id == client_service.id
    end

    test "returns a valid token struct and hashed token with user_id assign" do
      client_service = insert(:client_service)
      user = insert(:user)

      {token, user_token} =
        UserToken.build_email_token("email@gmail.com", "confirm", client_service.id, user.id)

      assert token != user_token.token
      assert user_token.context == "confirm"
      assert user_token.sent_to == "email@gmail.com"
      assert user_token.user_id == user.id
    end
  end
end
