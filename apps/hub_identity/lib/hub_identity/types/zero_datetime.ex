defmodule HubIdentity.Types.ZeroDateTime do
  @moduledoc false
  use Ecto.Type

  def type, do: :naive_datetime

  def cast(data), do: {:ok, data}

  # Just return `nil` datetime instead of crashing.
  def load(:zero_datetime), do: {:ok, nil}

  def load(%NaiveDateTime{} = data), do: {:ok, data}

  def dump(%NaiveDateTime{} = data), do: {:ok, data}

  def dump(_), do: :error

  def from_unix!(integer, unit) do
    DateTime.from_unix!(integer, unit)
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end
end
