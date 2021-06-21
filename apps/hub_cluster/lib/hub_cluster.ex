defmodule HubCluster do
  @moduledoc """
  Documentation for `HubCluster`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> HubCluster.restart_mnesia()
      :world

  """
  def restart_mnesia(nodes \\ Node.list()) do
    Memento.stop()
    # Memento.Schema.create(nodes) Only if we persist to disk.
    Memento.start()
    Memento.add_nodes([node() | nodes])
  end
end
