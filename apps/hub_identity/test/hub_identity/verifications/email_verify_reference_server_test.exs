defmodule HubIdentity.Verifications.EmailVerifyReferenceServerTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubCluster.MementoRepo
  alias HubIdentity.Identities
  alias HubIdentity.Verifications.{EmailVerifyReference, EmailVerifyReferenceServer}

  describe "create_reference/2" do
    test "generate and save email verify reference" do
      MementoRepo.clear(EmailVerifyReference)

      {:ok, user} = Identities.user_registration_changeset(%{password: "LongPassword!"})

      client_service = insert(:client_service)

      attrs = %{
        address: "erin@hivelocity.co.jp",
        client_service_uid: client_service.uid,
        provider_info: "self",
        redirect_url: "redirect/url",
        user: user
      }

      assert MementoRepo.all(EmailVerifyReference) == []

      {:ok, %EmailVerifyReference{reference: reference}} =
        EmailVerifyReferenceServer.create_reference(attrs)

      email_verify_reference = MementoRepo.all(EmailVerifyReference) |> hd()

      assert email_verify_reference.id != nil
      assert email_verify_reference.address == "erin@hivelocity.co.jp"
      assert email_verify_reference.expires_at != nil
      assert email_verify_reference.provider_info == "self"
      assert email_verify_reference.redirect_url == "redirect/url"
      assert email_verify_reference.reference == reference
      assert email_verify_reference.user == user
    end
  end
end
