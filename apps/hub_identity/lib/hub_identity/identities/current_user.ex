defmodule HubIdentity.Identities.CurrentUser do
  @moduledoc """
  CurrentUsers will be sent to ClientServices after a user has successfully authenticated.
  The Client Service requests the CurrentUser with the access_token provided in the redirect.
  """
  alias HubIdentity.Identities
  alias HubIdentity.Identities.{Email, User}

  defstruct [:uid, :email, :authenticated_at, :authenticated_by]

  def build(%User{uid: uid} = user, provider) do
    %__MODULE__{
      uid: uid,
      email: get_primary_email(user),
      authenticated_by: selfless(provider),
      authenticated_at: now()
    }
  end

  def build(%User{uid: uid}, address, provider) do
    %__MODULE__{
      uid: uid,
      email: address,
      authenticated_by: selfless(provider),
      authenticated_at: now()
    }
  end

  defp selfless("self"), do: "HubIdentity"

  defp selfless(name), do: name

  defp now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601()
  end

  defp get_primary_email(user) do
    with {:ok, %Email{address: address}} <- Identities.get_user_primary_email(user) do
      address
    else
      _ -> "none"
    end
  end
end
