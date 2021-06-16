defmodule HubPayments.Shared.Setting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field :active, :boolean, default: false
    field :description, :string
    field :env, :string
    field :key, :string
    field :type, :string
    field :value, :string

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:key, :value, :description, :active, :type, :env])
    |> validate_required([:key, :value, :description, :active, :type, :env])
  end
end
