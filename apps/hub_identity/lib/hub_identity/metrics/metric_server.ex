defmodule HubIdentity.Metrics.MetricServer do
  use GenServer

  alias HubIdentity.Repo
  alias HubIdentity.Metrics.UserActivity

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_), do: {:ok, %{}}

  def create_resource_activity(conn, attrs) do
    process(&__MODULE__.resource_created_activity/2, attrs, conn)
  end

  def create_authenticate_activity(conn, attrs) do
    process(&__MODULE__.authenticated_activity/2, attrs, conn)
  end

  def delete_resource_activity(conn, attrs) do
    process(&__MODULE__.resource_deleted_activity/2, attrs, conn)
  end

  def delete_resource_activity(attrs) do
    process(&__MODULE__.resource_deleted_activity/2, attrs, nil)
  end

  def handle_cast({:create_activity, fun, attrs, conn}, _state) do
    fun.(attrs, conn)
    {:noreply, %{}}
  end

  defp process(fun, attrs, conn) do
    case Application.get_env(:hub_identity, :async_cast) do
      false -> fun.(attrs, conn)
      _ -> GenServer.cast(__MODULE__, {:create_activity, fun, attrs, conn})
    end
  end

  def authenticated_activity(attrs, conn) do
    %UserActivity{}
    |> UserActivity.changeset(attrs, conn)
    |> Repo.insert()
  end

  def resource_created_activity(attrs, conn) do
    %UserActivity{}
    |> UserActivity.create_changeset(attrs, conn)
    |> Repo.insert()
  end

  def resource_deleted_activity(attrs, conn) do
    %UserActivity{}
    |> UserActivity.delete_changeset(attrs, conn)
    |> Repo.insert()
  end
end
