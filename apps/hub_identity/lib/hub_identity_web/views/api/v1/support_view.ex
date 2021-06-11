defmodule HubIdentityWeb.Api.V1.SupportView do
  @moduledoc false
  use HubIdentityWeb, :view

  alias HubIdentityWeb.Api.V1.SupportView

  def render("certs.json", %{keys: keys}) do
    render_many(keys, SupportView, "cert.json")
  end

  def render("cert.json", %{support: %{e: e, kty: kty, n: n, kid: kid, expires: expires}}) do
    %{
      alg: "RS256",
      e: e,
      kty: kty,
      n: n,
      kid: kid,
      expires: expires,
      use: "sig"
    }
  end
end
