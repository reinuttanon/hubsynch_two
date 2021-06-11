defmodule HubLedger.Ledgers.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias HubLedger.Accounts.Account
  alias HubLedger.Accounts

  @kinds ["credit", "debit"]

  schema "transactions" do
    field :money, Money.Ecto.Map.Type
    field :description, :string
    field :kind, :string
    field :reported_date, :utc_datetime
    field :uuid, :string
    field :account_uuid, :string, virtual: true

    belongs_to :account, Account
    belongs_to :entry, HubLedger.Ledgers.Entry

    timestamps()
  end

  @doc false
  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:money, :description, :kind, :reported_date, :account_id, :account_uuid])
    |> put_account_id()
    |> delete_change(:account_uuid)
    |> validate_required([:money, :description, :kind, :account_id])
    |> validate_inclusion(:kind, @kinds)
    |> default_reported_date()
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  defp default_reported_date(changeset) do
    case get_change(changeset, :reported_date) do
      nil -> put_change(changeset, :reported_date, now())
      _ -> changeset
    end
  end

  defp now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end

  defp put_account_id(changeset) do
    with account_uuid when is_binary(account_uuid) <- get_change(changeset, :account_uuid),
         %Account{id: account_id} <- Accounts.get_account(%{uuid: account_uuid}) do
      put_change(changeset, :account_id, account_id)
    else
      _ -> changeset
    end
  end
end
