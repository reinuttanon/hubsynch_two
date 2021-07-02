defmodule HubIdentity.UUID do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      defp generate_uuid, do: Ecto.UUID.generate()

      defp put_uuid(%Ecto.Changeset{valid?: true} = changeset) do
        Ecto.Changeset.put_change(changeset, :uuid, generate_prefix(changeset) <> generate_uuid())
      end

      defp put_uuid(changeset), do: changeset

      defp generate_prefix(%Ecto.Changeset{valid?: true} = changeset) do
        prefix =
          String.split("#{changeset.data.__struct__}", ".")
          |> List.last()
          |> Macro.underscore()

        prefix <> "_"
      end
    end
  end
end
