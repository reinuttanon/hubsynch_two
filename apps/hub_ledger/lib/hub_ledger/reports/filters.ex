defmodule HubLedger.Reports.Filters do
  defmacro __using__(_opts) do
    quote do
      import Ecto.Query, warn: false

      def description(query, description) do
        like = "%#{description}%"

        from q in query,
          where: like(q.description, ^like)
      end

      def owner(query, %{object: object, uid: uid}) do
        from q in query,
          where: fragment("owner->>'object' = ? AND owner->>'uid' = ?", ^object, ^uid)
      end

      def owner(query, %{object: object}) do
        from q in query,
          where: fragment("owner->>'object' = ?", ^object)
      end

      def owner(query, %{uid: uid}) do
        from q in query,
          where: fragment("owner->>'uid' = ?", ^uid)
      end

      def preload(query, items) do
        from q in query,
          preload: ^items
      end

      def uuid(query, uuid) do
        from q in query,
          where: q.uuid == ^uuid
      end

      def uuids(query, uuids) do
        from q in query,
          where: q.uuid in ^uuids
      end

      def select_ids(query) do
        from q in query,
          select: q.id
      end

      def limit(query, max) do
        from q in query,
          limit: ^max
      end
    end
  end
end
