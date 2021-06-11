defmodule HubPayments.Repo.Migrations.CreatePoints do
  use Ecto.Migration

  def change do
    create table(:points) do
      add :reference, :string
      add :request_date, :utc_datetime
      add :process_date, :utc_datetime
      add :settle_date, :utc_datetime
      add :money, :map, default: %{}
      add :uuid, :string
      add :owner, :map, default: %{}

      timestamps()
    end

  end
end
