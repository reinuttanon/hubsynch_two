defmodule HubIdentity.Providers.FacebookTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Providers.Facebook

  describe "parse_delete_request/2" do
    test "returns the provider_id with a valid request" do
      request = facebook_request()

      provider_config =
        insert(:provider_config, name: "facebook", client_secret: "client_secret_shhhhhh!")

      assert {:ok, "218471"} =
               Facebook.parse_delete_request(provider_config, %{"signed_request" => request})
    end

    test "returns error if invalid signature" do
      request = facebook_request()

      provider_config =
        insert(:provider_config, name: "facebook", client_secret: "wrong_secret_here_yall")

      assert {:error, :data_deletion_signature_failure} =
               Facebook.parse_delete_request(provider_config, %{"signed_request" => request})
    end

    test "returns error if invalid data" do
      provider_config =
        insert(:provider_config, name: "facebook", client_secret: "client_secret_shhhhhh!")

      request = "eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTE4"

      assert {:error, :data_deletion_failure} =
               Facebook.parse_delete_request(provider_config, %{"signed_request" => request})

      # valid signature, malformed data
      request =
        "kg9hjIz-mIvrrwRkue8sjfmFTJ5MuDE1V5MhhXtg7t0.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTE4NDA0MDAsImlzc3VlZF9hdCI6MTI5MTgzNjgwMCwib3RoZXJfa2V5IjoiMjE4NDcxIn0"

      assert {:error, :data_deletion_failure} =
               Facebook.parse_delete_request(provider_config, %{"signed_request" => request})
    end
  end

  defp facebook_request do
    # The following was reversed engineered from the Facebook docuemenation using the secret: "client_secret_shhhhhh!"
    # the data is:
    # %{
    #    algorithm: "HMAC-SHA256",
    #    expires: 1291840400,
    #    issued_at: 1291836800,
    #    user_id: "218471"
    # }
    "w5ZbbWP9yOwBA1uJZbc7-9gZok0O42U4i0yyvxXE_jY.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTE4NDA0MDAsImlzc3VlZF9hdCI6MTI5MTgzNjgwMCwidXNlcl9pZCI6IjIxODQ3MSJ9"
  end
end
