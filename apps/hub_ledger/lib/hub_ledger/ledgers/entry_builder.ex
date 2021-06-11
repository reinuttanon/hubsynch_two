defmodule HubLedger.Ledgers.EntryBuilder do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entry_builders" do
    field :active, :boolean, default: true
    field :json_config, :map
    field :name, :string
    field :string_config, :string, virtual: true
    field :uuid, :string

    timestamps()
  end

  @doc false
  def changeset(entry_builder, attrs) do
    entry_builder
    |> cast(attrs, [:active, :name, :json_config, :string_config])
    |> validate_required([:name])
    |> put_json_config()
    |> put_uuid()
  end

  def update_changeset(entry_builder, attrs) do
    entry_builder
    |> cast(attrs, [:active, :name, :json_config, :string_config])
    |> validate_required([:name])
    |> put_json_config()
  end

  defp put_json_config(%Ecto.Changeset{changes: %{json_config: json_config}} = changeset)
       when is_map(json_config),
       do: changeset

  defp put_json_config(changeset) do
    with string_config when is_binary(string_config) <- get_change(changeset, :string_config),
         {:ok, json_config} <- Jason.decode(string_config) do
      put_change(changeset, :json_config, json_config)
    else
      nil -> add_error(changeset, :json_config, "can't be blank", validation: :required)
      {:error, _} -> add_error(changeset, :json_config, "is invalid JSON", validation: :required)
    end
  end

  defp put_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    put_change(changeset, :uuid, Ecto.UUID.generate())
  end

  defp put_uuid(changeset), do: changeset
end
