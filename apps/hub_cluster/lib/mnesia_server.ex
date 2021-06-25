defmodule HubCluster.MnesiaServer do
  use GenServer

  require Logger

  alias HubCluster.MementoRepo

  @wait_timeout 10000

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    # for table <- MementoRepo.tables() do
    #   MementoRepo.create_table(table)
    # end

    # :ok = :mnesia.wait_for_tables(MementoRepo.tables(), @wait_timeout)
    {:ok, %{}}
  end
end

# Memento.add_nodes(Node.list())
# Memento.info
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
# iex(my_app@127.0.0.1)1> HubCluster.MementoRepo.setup(nodes)
# :ok
# ```
# You can alternatively provide a list of nodes for
# which you would like to create the schema:
# ```
# iex(my_app@host_x)1> nodes = [node() | Node.list]
# [:my_app@host_x, :my_app@host_y, :my_app@host_z]
# iex(my_app@node_x)2> HubCluster.MementoRepo.setup(nodes)
# :ok
# ```

# def setup(nodes \\ [node() | Node.list()]) do
# :ok = File.mkdir_p!(@path)

# Create the Schema
# Memento.stop()
# Memento.Schema.create(nodes)
# Memento.start()

# with [:ok] <- create_tables(nodes),
#      :ok <- :mnesia.wait_for_tables(@disk_tables) do
#   :ok
# end
# end

# defp create_tables(nodes) do
#   Enum.map(@disk_tables, fn table -> create_table(table, disc_copies: nodes) end)
#   |> Enum.uniq()
# end
