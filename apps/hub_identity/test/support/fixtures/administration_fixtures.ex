defmodule HubIdentity.AdministrationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HubIdentity.Administration` context.
  """

  def unique_administrator_email, do: "administrator#{System.unique_integer()}@example.com"
  def valid_administrator_password, do: "LongPassword!"

  def administrator_fixture(attrs \\ %{}) do
    {:ok, administrator} =
      attrs
      |> Enum.into(%{
        email: unique_administrator_email(),
        password: valid_administrator_password()
      })
      |> HubIdentity.Administration.register_administrator()

    administrator
  end

  def sys_administrator_fixture do
    administrator_fixture(%{system: true})
  end

  def extract_administrator_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
