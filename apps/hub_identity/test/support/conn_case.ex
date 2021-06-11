defmodule HubIdentityWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use HubIdentityWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  @repos [HubIdentity.Repo]

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import HubIdentityWeb.ConnCase

      require IEx

      alias HubIdentityWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint HubIdentityWeb.Endpoint
    end
  end

  setup tags do
    for repo <- @repos do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(repo)

      unless tags[:async] do
        Ecto.Adapters.SQL.Sandbox.mode(repo, {:shared, self()})
      end
    end

    on_exit(fn -> Memento.Table.clear(HubIdentity.ClientServices.StateSecret) end)
    on_exit(fn -> Memento.Table.clear(HubIdentity.Providers.Oauth2Provider) end)
    on_exit(fn -> Memento.Table.clear(HubIdentityWeb.Authentication.AccessCookie) end)
    on_exit(fn -> Memento.Table.clear(HubIdentity.Verifications.EmailVerifyReference) end)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in a system administrators.

      setup :register_and_log_in_sys_administrator

  It stores an updated connection and a registered administrator in the
  test context.
  """
  def register_and_log_in_sys_administrator(%{conn: conn}) do
    administrator = HubIdentity.AdministrationFixtures.sys_administrator_fixture()
    %{conn: log_in_administrator(conn, administrator), administrator: administrator}
  end

  @doc """
  Setup helper that registers and logs in administrators.

      setup :register_and_log_in_administrator

  It stores an updated connection and a registered administrator in the
  test context.
  """
  def register_and_log_in_administrator(%{conn: conn}) do
    administrator = HubIdentity.AdministrationFixtures.administrator_fixture()
    %{conn: log_in_administrator(conn, administrator), administrator: administrator}
  end

  @doc """
  Logs the given `administrator` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_administrator(conn, administrator) do
    token = HubIdentity.Administration.generate_administrator_session_token(administrator)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:administrator_token, token)
  end
end
