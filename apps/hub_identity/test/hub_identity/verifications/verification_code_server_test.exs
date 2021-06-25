defmodule HubIdentity.Verifications.VerificationCodeServerTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubCluster.MementoRepo
  alias HubIdentity.Identities
  alias HubIdentity.Verifications.{VerificationCode, VerificationCodeServer}

  describe "generate_code/2" do
    test "generate and save a verification code" do
      MementoRepo.clear(VerificationCode)
      user = insert(:user)
      insert(:email, user: user, primary: true)
      client_service = insert(:client_service)
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      assert MementoRepo.all(VerificationCode) == []

      loaded_user = Identities.get_user(%{uid: user.uid})

      :ok = VerificationCodeServer.generate_code(loaded_user, client_service, reference)

      verification_code = MementoRepo.all(VerificationCode) |> hd()
      assert verification_code.code != nil
      assert verification_code.user_uid == user.uid
      assert verification_code.client_service_uid == client_service.uid
      assert verification_code.reference == reference
      assert verification_code.attempts == 0
    end

    test "with invalid reference returns error" do
      user = insert(:user)
      client_service = insert(:client_service)

      assert {:error, "invalid reference should be between 22 and 44 characters"} =
               VerificationCodeServer.generate_code(user, client_service, "tooshort")
    end
  end
end
