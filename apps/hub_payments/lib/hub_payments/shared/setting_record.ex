defmodule HubPayments.Shared.SettingRecord do
  @moduledoc false
  alias HubPayments.Shared.Setting

  use Memento.Table,
    attributes: [:key, :value, :env],
    type: :set

  @doc false
  def create_changeset(%Setting{key: key, env: env, value: value}) do
    %__MODULE__{
      key: key,
      value: value,
      env: env
    }
  end
end
