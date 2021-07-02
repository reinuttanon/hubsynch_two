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

client_services_params = [
  %{
    description: "this was born from a seed",
    name: "erin's service",
    redirect_url: "http://www.whizzletooth.co/redirect",
    url: "www.whizzletooth.co",
    logo: "https://www.glay.co.jp/img/uploads/index_contents/201901010322_02123.jpg",
    email_confirmation_redirect_url: "email/confirm/required",
    pass_change_redirect_url: "passwrod/change/redirect"
  },
  %{
    description: "this was born from a seed",
    name: "patrick's service",
    redirect_url: "http://www.youtube.co/redirect",
    url: "www.youtube.co",
    logo: "https://www.glay.co.jp/img/uploads/index_contents/201901010322_02123.jpg",
    email_confirmation_redirect_url: "email/confirm/required",
    pass_change_redirect_url: "passwrod/change/redirect"
  },
  %{
    description: "this was born from a seed",
    name: "natali's service",
    redirect_url: "http://www.pink_unikorn.co/redirect",
    url: "www.pink_unikorn.co",
    logo: "https://www.glay.co.jp/img/uploads/index_contents/201901010322_02123.jpg",
    email_confirmation_redirect_url: "email/confirm/required",
    pass_change_redirect_url: "passwrod/change/redirect"
  }
]

for client_services_param <- client_services_params do
  if Repo.get_by(ClientService, name: client_services_param[:name]) == nil do
    admin = Administration.get_administrator_by_email("erin@hivelocity.co.jp")
    ClientServices.create_client_service(client_services_param, admin)
  end
end
