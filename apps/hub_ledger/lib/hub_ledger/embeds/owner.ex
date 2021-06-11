defmodule HubLedger.Embeds.Owner do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :object
    field :uid
  end

  def changeset(owner, attrs) do
    owner
    |> cast(attrs, [:object, :uid])
  end
end
