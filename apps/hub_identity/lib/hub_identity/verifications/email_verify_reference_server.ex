defmodule HubIdentity.Verifications.EmailVerifyReferenceServer do
  use GenServer

  alias HubCluster.MementoRepo
  alias HubIdentity.Verifications.EmailVerifyReference

  # Max age in miliseconds
  @expiration EmailVerifyReference.max_age() * 1000

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    MementoRepo.create_table(EmailVerifyReference)
    {:ok, %{}}
  end

  def create_reference(attrs) do
    GenServer.call(__MODULE__, {:create_reference, attrs})
  end

  def handle_info({:expire, id}, state) do
    MementoRepo.withdraw(EmailVerifyReference, id)
    {:noreply, state}
  end

  def handle_call({:create_reference, attrs}, _from, state) do
    with %EmailVerifyReference{} = changeset <-
           EmailVerifyReference.create_changeset(attrs),
         {:ok, %EmailVerifyReference{id: id} = reference} <- MementoRepo.insert(changeset),
         {:ok, _reference} <- :timer.send_after(@expiration, {:expire, id}) do
      {:reply, {:ok, reference}, state}
    else
      {:error, message} -> {:reply, {:error, message}, state}
    end
  end

  def get_email_verify_reference(%{client_service_uid: client_service_uid, address: address}) do
    query = {:and, {:==, :client_service_uid, client_service_uid}, {:==, :address, address}}

    MementoRepo.get(EmailVerifyReference, query)
  end
end
