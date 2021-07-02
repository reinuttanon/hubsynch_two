defmodule HubIdentity.Uid do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      defp generate_uid, do: Ecto.UUID.generate()

      defp put_uid(%Ecto.Changeset{valid?: true} = changeset) do
        Ecto.Changeset.put_change(changeset, :uid, generate_prefix(changeset) <> generate_uid())
      end

      defp put_uid(changeset), do: changeset

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
