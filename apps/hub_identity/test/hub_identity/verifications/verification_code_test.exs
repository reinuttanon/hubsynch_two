defmodule HubIdentity.Verifications.VerificationCodeTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Verifications.VerificationCode

  describe "create_changeset/2" do
    test "with a user and a client service returns a VerificationCode struct" do
      user = insert(:user)
      client_service = insert(:client_service)
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      verification_code = VerificationCode.create_changeset(user, client_service, reference)

      assert verification_code.code >= 1_000 and verification_code.code <= 9_999
      assert verification_code.user_uid == user.uid
      assert verification_code.client_service_uid == client_service.uid
      assert verification_code.expires_at != nil
      assert verification_code.reference == reference
      assert verification_code.attempts == 0
    end

    test "with invalid size reference returns error" do
      user = insert(:user)
      client_service = insert(:client_service)

      assert {:error, "invalid reference should be between 22 and 44 characters"} =
               VerificationCode.create_changeset(user, client_service, "tooshort")

      too_long = :crypto.strong_rand_bytes(34) |> Base.url_encode64(padding: false)

      assert {:error, "invalid reference should be between 22 and 44 characters"} =
               VerificationCode.create_changeset(user, client_service, too_long)
    end
  end
end
