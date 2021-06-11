defmodule HubLedger.HttpTester do
  def get(%{uid: _}) do
    {:ok, %{"emails" => [%{"address" => "test@hivelocity.co.jp", "primary" => true}]}}
  end

  def get_providers() do
    {:ok, ["", %{"name" => "google", "request_url" => "google_request_url"}]}
  end

  def get_current_user(user_token) do
    case user_token do
      "valid_token" -> {:ok, %{"email" => "some_email", "uid" => "some_uid"}}
      _ -> {:error, "Invalid Token"}
    end
  end
end
