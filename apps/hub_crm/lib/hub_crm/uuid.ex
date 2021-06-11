defmodule HubCrm.Uuid do
  defmacro __using__(_opts) do
    quote do
      defp generate_uid, do: Ecto.UUID.generate()

      defp put_uid(%Ecto.Changeset{valid?: true} = changeset) do
        Ecto.Changeset.put_change(changeset, :uid, generate_uid())
      end

      defp put_uid(changeset), do: changeset
    end
  end
end
