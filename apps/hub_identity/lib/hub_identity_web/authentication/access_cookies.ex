defmodule HubIdentityWeb.Authentication.AccessCookie do
  @moduledoc false
  import HubIdentity.Encryption.Helpers, only: [generate_data: 0]

  @cookie_name "_hub_identity_access"
  @max_age 86_400

  use Memento.Table,
    attributes: [:id, :owner, :expires_at],
    index: [:expires_at],
    type: :set

  def create_changeset(owner, expires_at) do
    %__MODULE__{
      id: generate_data(),
      owner: owner,
      expires_at: expires_at
    }
  end

  def cookie_name, do: @cookie_name

  def max_age, do: @max_age
end
