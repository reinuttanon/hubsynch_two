defmodule HubIdentity.Encryption.JWKCert do
  use Memento.Table,
    attributes: [:kid, :public_key, :private_key, :expires],
    index: [:public_key],
    type: :set

  def changeset(%JOSE.JWK{} = jwk, expires) do
    kid = JOSE.JWK.thumbprint(jwk)

    public_key = JOSE.JWK.to_public(jwk) |> JOSE.JWK.merge(%{"kid" => kid})

    private_key = JOSE.JWK.merge(jwk, %{"kid" => kid})

    %__MODULE__{
      kid: kid,
      public_key: public_key,
      private_key: private_key,
      expires: expires
    }
  end
end
