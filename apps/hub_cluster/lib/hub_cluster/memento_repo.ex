defmodule HubCluster.MementoRepo do
  use GenServer

  require Logger

  @mnesia_manager Application.get_env(:hub_cluster, :mnesia_manager)

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {add_mnesia_manager(), %{nodes: [node() | Node.list()]}}
  end

  @doc """
  Get all of an object

  ## Examples

      iex> all(StateSecret)
      [%StateSecret{}, %StateSecret{}, ..]

      iex> all(StateSecret)
      nil

  """
  def all(object) do
    Memento.transaction!(fn ->
      Memento.Query.all(object)
    end)
  end

  @doc """
  Get all records matching the given query.
  https://hexdocs.pm/memento/Memento.Query.html#select/3

  ## Examples

      iex> get(StateSecret, {:==, :secret, "secret"})
      {:ok, [%StateSecret{}, %StateSecret{}, ..]}

      iex> get(StateSecret, {:==, :secret, "secret"})
      {:ok, []}

  """
  def get(object, query) do
    Memento.transaction(fn ->
      Memento.Query.select(object, query)
    end)
  end

  @doc """
  Get all records matching the given query.
  https://hexdocs.pm/memento/Memento.Query.html#select/3

  ## Examples

      iex> get!(StateSecret, {:==, :secret, "secret"})
      [%StateSecret{}, %StateSecret{}, ..]

      iex> get!(StateSecret, {:==, :secret, "secret"})
      []

  """

  def get!(object, query) do
    Memento.transaction!(fn ->
      Memento.Query.select(object, query)
    end)
  end

  @doc """
  Get a record by the id.
  https://hexdocs.pm/memento/Memento.Query.html#read/3

  ## Examples

      iex> get_one(StateSecret, 1)
      %StateSecret{}

      iex> get_one(StateSecret, 1)
      nil

  """
  def get_one(object, id) do
    Memento.transaction!(fn ->
      Memento.Query.read(object, id)
    end)
  end

  def select_raw(object, query) do
    Memento.transaction!(fn ->
      Memento.Query.select_raw(object, query)
    end)
  end

  @doc """
  Save a record.
  https://hexdocs.pm/memento/Memento.Query.html#write/2

  ## Examples

      iex> insert(%StateSecret{})
      {:ok, %StateSecret{}}

  """
  def insert(object) do
    Memento.transaction(fn ->
      Memento.Query.write(object)
    end)
  end

  @doc """
  Save a record.
  https://hexdocs.pm/memento/Memento.Query.html#write/2

  ## Examples

      iex> insert!(%StateSecret{})
      %StateSecret{}

  """
  def insert!(object) do
    Memento.transaction!(fn ->
      Memento.Query.write(object)
    end)
  end

  @doc """
  Delete a record.
  https://hexdocs.pm/memento/Memento.Query.html#delete_record/2

  ## Examples

      iex> delete(%StateSecret{})
      :ok

  """
  def delete(object) do
    Memento.transaction!(fn ->
      Memento.Query.delete_record(object)
    end)
  end

  def clear(table) do
    :mnesia.clear_table(table)
  end

  @doc """
  Find and delete a record by query. This will only delete the first
  record returned by the query.

  When a value does not exist will return {:ok, []} showing the query
  succeeded and nothing was found.

  ## Examples

      iex> withdraw(StateSecret, {:==, :secret, "secret"})
      {:ok, %StateSecret{}}

      iex> withdraw(StateSecret, 1)
      {:ok, %StateSecret{id: 1}}

      iex> withdraw(StateSecret, 1)
      {:ok, {:error, "Elixir.HubCluster.StateSecrets.StateSecret not found"}}

  """
  def withdraw(object, query) when is_tuple(query) do
    Memento.transaction!(fn ->
      case Memento.Query.select(object, query) do
        [record | _tail] -> delete_return(record)
        [] -> {:error, "#{object} not found"}
      end
    end)
  end

  def withdraw(object, query) when is_list(query) do
    Memento.transaction!(fn ->
      case Memento.Query.select(object, query) do
        [record | _tail] -> delete_return(record)
        [] -> {:error, "#{object} not found"}
      end
    end)
  end

  def withdraw(object, id) do
    Memento.transaction!(fn ->
      case Memento.Query.read(object, id) do
        nil -> {:error, "#{object} not found"}
        record -> delete_return(record)
      end
    end)
  end

  def create_table(table) do
    options = Application.get_env(:hub_cluster, :mnesia_options)

    with :ok <- Memento.Table.create(table, options) do
      Logger.info("successfully created table: #{table}")
    else
      {:error, {:already_exists, _}} -> copy_table(table)
      {:error, message} -> Logger.error("Memento.Table.create failed with: #{message}")
    end
  end

  defp add_mnesia_manager do
    {:ok, _} = :mnesia.change_config(:extra_db_nodes, [@mnesia_manager])
    :ok
  end

  defp copy_table(table) do
    case Memento.Table.create_copy(table, node(), :ram_copies) do
      :ok ->
        Logger.info("successfully copied table: #{table}")

      {:error, {:already_exists, _, _}} ->
        Logger.info("table already exists and recovered: #{table}")

      {:error, message} ->
        Logger.error("failed to copy table: #{table} with: #{message}")
    end
  end

  defp delete_return(record) do
    Memento.Query.delete_record(record)
    {:ok, record}
  end
end
