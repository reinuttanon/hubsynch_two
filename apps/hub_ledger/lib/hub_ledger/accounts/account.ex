defmodule HubLedger.Accounts.Account do
  use Ecto.Schema

  import Ecto.Changeset

  alias HubLedger.Embeds.Owner

  @credit_types ["equity", "liability", "revenue"]
  @debit_types ["asset", "expense"]
  @types (@credit_types ++ @debit_types) |> Enum.sort()

  schema "accounts" do
    field :active, :boolean, default: true
    field :currency, :string
    field :kind, :string
    field :meta_data, :map, default: %{}
    field :name, :string
    field :type, :string
    field :uuid, :string

    embeds_one :owner, Owner, on_replace: :update

    has_one :balance, HubLedger.Accounts.Balance

    timestamps()
  end

  @doc false
  def create_changeset(account, attrs) do
    account
    |> cast(attrs, [:currency, :meta_data, :name, :type])
    |> cast_embed(:owner, with: &Owner.changeset/2)
    |> validate_required([:currency, :name, :type])
    |> validate_inclusion(:type, @types)
    |> set_kind()
    |> validate_currency()
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def types(), do: @types

  def update_changeset(account, attrs) do
    account
    |> cast(attrs, [:active, :meta_data, :name])
    |> cast_embed(:owner, with: &Owner.changeset/2)
    |> validate_required([:name])
  end

  defp set_kind(%Ecto.Changeset{valid?: true, changes: %{type: type}} = changeset) do
    case Enum.member?(@debit_types, type) do
      true -> put_change(changeset, :kind, "debit")
      false -> put_change(changeset, :kind, "credit")
    end
  end

  defp set_kind(changeset), do: changeset

  def validate_currency(%Ecto.Changeset{valid?: true, changes: %{currency: currency}} = changeset) do
    case Money.Currency.exists?(currency) do
      true -> changeset
      false -> add_error(changeset, :currency, "is invalid", [{:validation, :required}])
    end
  end

  def validate_currency(changeset), do: changeset
end
