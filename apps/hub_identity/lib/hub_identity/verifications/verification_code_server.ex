defmodule HubIdentity.Verifications.VerificationCodeServer do
  use GenServer

  alias HubIdentity.{Identities, MementoRepo}
  alias HubIdentity.Verifications.VerificationCode

  # Max age in miliseconds
  @expiration VerificationCode.max_age() * 1000

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    HubIdentity.MementoRepo.create_table(VerificationCode)
    {:ok, %{}}
  end

  @doc """
  Generates an random verification code and sends email with it to do 2 factor verification.

  ## Examples
    iex> generate_code(user, client_service, reference)
    :ok

    iex> generate_code(user, client_service, invalid_reference)
    {:error, message}
  """
  def generate_code(user, client_service, reference) do
    with %VerificationCode{} = verification_code <-
           VerificationCode.create_changeset(user, client_service, reference) do
      process(verification_code, user, client_service)
      # return :ok to mimic handle_cast response
      :ok
    else
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Sends the verification email with a verification code.
  """
  def handle_cast({:insert_code_and_send_email, verification_code, user, client_service}, state) do
    {code, _full_email, user_uid} =
      insert_code_and_send_email(verification_code, user, client_service)

    {:ok, _reference} = :timer.send_after(@expiration, {:expire, code, user_uid})
    {:noreply, state}
  end

  @doc """
  Withdraws an expired verification reference.
  """
  def handle_info({:expire, code, user_uid}, state) do
    query = [
      {:==, :code, code},
      {:==, :user_uid, user_uid}
    ]

    MementoRepo.withdraw(VerificationCode, query)
    {:noreply, state}
  end

  defp insert_code_and_send_email(verification_code, user, client_service) do
    {:ok, %VerificationCode{code: code, user_uid: user_uid}} =
      MementoRepo.insert(verification_code)

    {:ok, email} = Identities.get_user_primary_email(user)
    {:ok, sent_message} = Identities.deliver_verification_code(email, client_service, code)
    {code, sent_message, user_uid}
  end

  defp process(verification_code, user, client_service) do
    case Application.get_env(:hub_identity, :async_cast) do
      false ->
        insert_code_and_send_email(verification_code, user, client_service)

      _ ->
        GenServer.cast(
          __MODULE__,
          {:insert_code_and_send_email, verification_code, user, client_service}
        )
    end
  end
end
