defmodule HubIdentity.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HubIdentity.Identities` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  def valid_user_password, do: "LongPassword!"

  # This will return the result of Identities.handle_confirmation
  # {:ok, %{email: %Email{}, user: %User{}}}

  def user_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      "email" => unique_user_email(),
      "password" => valid_user_password()
    })
    |> HubIdentity.Identities.handle_confirmation()
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
