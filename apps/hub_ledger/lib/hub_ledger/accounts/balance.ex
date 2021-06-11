defmodule HubLedger.Accounts.Balance do
  use Ecto.Schema
  import Ecto.Changeset

  alias HubLedger.Accounts.Account

  schema "balances" do
    field :active, :boolean, default: true
    field :kind, :string
    field :money, Money.Ecto.Map.Type
    field :uuid, :string

    belongs_to :account, Account

    timestamps()
  end

  @doc false
  def create_changeset(%Account{id: account_id, currency: currency, kind: kind}) do
    %__MODULE__{}
    |> change(%{account_id: account_id, money: Money.new(0, currency), kind: kind})
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def update_changeset(
        %__MODULE__{money: %Money{currency: currency}} = balance,
        %Money{currency: currency} = new_money
      ) do
    balance
    |> change(%{money: new_money})
  end

  def update_changeset(%__MODULE__{money: %Money{currency: currency}} = balance, _new_money) do
    balance
    |> cast(%{}, [])
    |> add_error(:money, "currency '%{currency}' must match", currency: currency)
  end
end
