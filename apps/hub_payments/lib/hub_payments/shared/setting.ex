defmodule HubPayments.Shared.Setting do
  use Ecto.Schema
  import Ecto.Changeset

  @types ["secret", "file_path", "url", "setting"]
  @envs ["development", "production", "staging"]

  schema "settings" do
    field :active, :boolean, default: true
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
    |> validate_required([:key, :value, :active, :type, :env])
    |> unique_constraint([:key, :env, :active])
    |> validate_inclusion(:type, @types)
    |> validate_inclusion(:env, @envs)
  end

  def envs, do: @envs
  def types, do: @types
end
