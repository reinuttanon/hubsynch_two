defmodule HubPayments.ReleaseTasks do
  @doc """
  Release tasks.

  Mix is not available when using releases, this will allow the ability
  to migrate databases.

  ## Examples
    _build/prod/rel/hub_crm/bin/hub_crm eval "HubPayments.Release.migrate"
  """
  @app :hub_payments

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    [HubPayments.Repo]
  end

  defp load_app do
    Application.load(@app)
  end
end
