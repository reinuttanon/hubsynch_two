defmodule HubIdentity.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: HubIdentity.Repo

  import HubIdentity.Encryption.Helpers, only: [generate_data: 1]

  alias HubIdentity.Administration.Administrator
  alias HubIdentity.ClientServices.{ApiKey, ClientService}
  alias HubIdentity.Identities.{Email, Identity, User}
  alias HubIdentity.Metrics.UserActivity
  alias HubIdentity.Providers.ProviderConfig

  def administrator_factory do
    %Administrator{
      email: sequence(:email, &"email-#{&1}@example.com"),
      hashed_password: "randomstring"
    }
  end

  def api_key_factory do
    %ApiKey{
      client_service: build(:client_service),
      data: generate_data(""),
      type: "public",
      uid: Ecto.UUID.generate(),
      deleted_at: nil
    }
  end

  def client_service_factory do
    %ClientService{
      description: "this is a test",
      name: "erins service",
      redirect_url: "http://www.whizzletooth.co/redirect",
      url: "www.whizzletooth.co",
      logo: "https://www.glay.co.jp/img/uploads/index_contents/201901010322_02123.jpg",
      email_confirmation_redirect_url: "email/confirm/required",
      pass_change_redirect_url: "passwrod/change/redirect",
      uid: Ecto.UUID.generate()
    }
  end

  def confirmed_email_factory do
    %Email{
      address: sequence(:email, &"erin-#{&1}@hivelocity.co.jp"),
      primary: true,
      uid: Ecto.UUID.generate(),
      confirmed_at: DateTime.utc_now(),
      user: build(:user)
    }
  end

  def email_factory do
    %Email{
      address: sequence(:email, &"erin-#{&1}@hivelocity.co.jp"),
      primary: false,
      uid: Ecto.UUID.generate(),
      user: build(:user)
    }
  end

  def identity_factory do
    %Identity{
      details: %{},
      reference: sequence(:provider_id, &"provider_#{&1}"),
      uid: Ecto.UUID.generate(),
      provider_config: build(:provider_config),
      user: build(:user)
    }
  end

  def provider_config_factory do
    %ProviderConfig{
      access_token_url: "www.access_token.url",
      auth_url: "http://www.auth_url",
      client_id: "client_id_123",
      client_secret: "client_secret_shhhhhh!",
      name: sequence(:name, &"twinner_#{&1}"),
      scopes: "see_everything.api, doo_everything.api",
      uid: Ecto.UUID.generate(),
      deleted_at: nil,
      active: true
    }
  end

  def user_activity_factory do
    %UserActivity{
      owner_type: "User",
      owner_uid: "user_uid_12345",
      provider: "HubIdentity",
      type: "User.create",
      uid: Ecto.UUID.generate(),
      client_service_uid: "uid_00001"
    }
  end

  def user_factory do
    %User{
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      uid: Ecto.UUID.generate()
    }
  end

  def webhook_client_service_factory do
    %ClientService{
      description: "this is a test",
      name: "erins service",
      redirect_url: "www.whizzletooth.co/redirect",
      url: "www.whizzletooth.co",
      webhook_auth_key: "webhook_auth_key",
      webhook_auth_type: "x-api-key",
      webhook_url: "www.webhook.url"
    }
  end

  def valid_user_password, do: "LongPassword"

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
