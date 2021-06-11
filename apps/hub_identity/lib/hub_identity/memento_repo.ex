defmodule HubIdentity.MementoRepo do
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
      {:ok, {:error, "Elixir.HubIdentity.StateSecrets.StateSecret not found"}}

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

  defp delete_return(record) do
    Memento.Query.delete_record(record)
    {:ok, record}
  end

  def create_table(table, opts \\ []) do
    case Memento.Table.create(table, opts) do
      :ok -> :ok
      {:error, {:already_exists, _}} -> :ok
      # log this in future
      {:error, msg} -> {:error, msg}
    end
  end
end

# Creates the Mnesia Database for `Que` on disk
# This creates the Schema, Database and Tables for
# Que Jobs on disk for the specified erlang nodes so
# Jobs are persisted across application restarts.
# Calling this momentarily stops the `:mnesia`
# application so you should make sure it's not being
# used when you do.
# If no argument is provided, the database is created
# for the current node.
# ## On Production
# For a compiled release (`Distillery` or `Exrm`),
# start the application in console mode or connect a
# shell to the running release and simply call the
# method:
# ```
# $ bin/my_app remote_console
# iex(my_app@127.0.0.1)1> HubIdentity.MementoRepo.setup(nodes)
# :ok
# ```
# You can alternatively provide a list of nodes for
# which you would like to create the schema:
# ```
# iex(my_app@host_x)1> nodes = [node() | Node.list]
# [:my_app@host_x, :my_app@host_y, :my_app@host_z]
# iex(my_app@node_x)2> HubIdentity.MementoRepo.setup(nodes)
# :ok
# ```

# def setup(nodes \\ [node()]) do
#   :ok = File.mkdir_p!(@path)

#   # Create the Schema
#   Memento.stop()
#   Memento.Schema.create(nodes)
#   Memento.start()

#   with [:ok] <- create_tables(nodes),
#        :ok <- :mnesia.wait_for_tables(@disk_tables) do
#     :ok
#   end
# end

# defp create_tables(nodes) do
#   Enum.map(@disk_tables, fn table -> create_table(table, disc_copies: nodes) end)
#   |> Enum.uniq()
# end
