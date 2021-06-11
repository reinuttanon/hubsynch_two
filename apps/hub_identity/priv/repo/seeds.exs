# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     HubIdentity.Repo.insert!(%HubIdentity.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias HubIdentity.Administration
alias HubIdentity.ClientServices
alias HubIdentity.ClientServices.ClientService
alias HubIdentity.Identities
alias HubIdentity.Providers
alias HubIdentity.Providers.ProviderConfig
alias HubIdentity.Repo

administrators = [
  %{
    email: "erin@hivelocity.co.jp",
    password: "LongPassword!",
    system: true
  }
]

for admin <- administrators do
  if Administration.get_administrator_by_email(admin[:email]) == nil do
    Administration.register_administrator(admin)
  end
end

client_service_administrators = [
  %{
    email: "yuko@hivelocity.co.jp",
    password: "LongPassword!"
  }
]

for admin <- client_service_administrators do
  if Administration.get_administrator_by_email(admin[:email]) == nil do
    Administration.register_administrator(admin)
  end
end

provider_configs = [
  %{
    access_token_url: "https://graph.facebook.com/v9.0/oauth/access_token",
    auth_url: "https://www.facebook.com/v9.0/dialog/oauth",
    client_id: "client_id_123",
    client_secret: "client_secret_shhhhhh!",
    name: "facebook",
    scopes: "email",
    active: true
  },
  %{
    access_token_url: "https://oauth2.googleapis.com/token",
    auth_url: "https://accounts.google.com/o/oauth2/v2/auth",
    client_id: "client_id_123",
    client_secret: "client_secret_shhhhhh!",
    name: "google",
    scopes: "https://www.googleapis.com/auth/userinfo.email",
    active: true
  }
]

for provider_config <- provider_configs do
  if Repo.get_by(ProviderConfig, name: provider_config[:name]) == nil do
    Providers.create_provider_config(provider_config)
  end
end
