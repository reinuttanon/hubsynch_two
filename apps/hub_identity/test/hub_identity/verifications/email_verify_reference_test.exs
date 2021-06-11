defmodule HubIdentity.Verifications.EmailVerifyReferenceTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Identities
  alias HubIdentity.Verifications.EmailVerifyReference

  describe "create_changeset/3" do
    test "Create valid email verify reference" do
      {:ok, user} = Identities.user_registration_changeset(%{password: "LongPassword!"})
      client_service = insert(:client_service)

      attrs = %{
        address: "erin@hivelocity.co.jp",
        client_service_uid: client_service.uid,
        provider_info: "self",
        redirect_url: "redirect/url",
        user: user
      }

      email_verify_reference = EmailVerifyReference.create_changeset(attrs)

      expires_at =
        DateTime.utc_now()
        |> DateTime.add(EmailVerifyReference.max_age(), :second)
        |> DateTime.to_unix()

      assert email_verify_reference.id == nil
      assert email_verify_reference.address == "erin@hivelocity.co.jp"
      assert email_verify_reference.client_service_uid == client_service.uid
      assert email_verify_reference.expires_at <= expires_at
      assert email_verify_reference.provider_info == "self"
      assert email_verify_reference.redirect_url == "redirect/url"
      assert email_verify_reference.reference != nil
      assert email_verify_reference.user == user
    end
  end
end
