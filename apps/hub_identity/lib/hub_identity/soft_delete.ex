defmodule HubIdentity.SoftDelete do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      def delete_changeset(ecto_schema) do
        ecto_schema
        |> Ecto.Changeset.cast(%{deleted_at: DateTime.utc_now()}, [:deleted_at])
      end
    end
  end
end
