defmodule HubLedgerWeb.ConnCase do
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
  by setting `use HubLedgerWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate
  import HubLedger.Factory

  @repos [HubLedger.Repo, HubIdentity.Repo]

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import HubLedgerWeb.ConnCase

      alias HubLedgerWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint HubLedgerWeb.Endpoint
    end
  end

  setup tags do
    for repo <- @repos do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(repo)

      unless tags[:async] do
        Ecto.Adapters.SQL.Sandbox.mode(repo, {:shared, self()})
      end
    end

    # on_exit(fn -> HubCluster.MementoRepo.clear_all() end)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in administrators.

      setup :register_and_log_in_administrator

  It stores an updated connection and a registered administrator in the
  test context.
  """
  def register_and_log_in_administrator(%{conn: conn}) do
    user = insert(:user, role: "admin", hub_identity_uid: "admin_hub_identity_uid")
    %{conn: log_in_administrator(conn, user), user: user}
  end

  @doc """
  Logs the given `administrator` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_administrator(conn, user) do
    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_id, user.id)
  end
end
