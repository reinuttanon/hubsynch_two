defmodule HubCrm.Types.ZeroDate do
  use Ecto.Type

  def type, do: :date

  def cast(data), do: {:ok, data}

  # Just return `nil` datetime instead of crashing.
  def load(:zero_date), do: {:ok, nil}
  def load(%Date{} = data), do: {:ok, data}

  def dump(%Date{} = data), do: {:ok, data}
  def dump(_), do: :error
end
