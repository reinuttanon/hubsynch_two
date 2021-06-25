defmodule HubIdentity.Verifications.VerificationCode do
  alias HubCluster.MementoRepo
  alias HubIdentity.ClientServices.ClientService
  alias HubIdentity.Identities.User

  @max_age 300
  @max_attempts 3

  use Memento.Table,
    attributes: [:code, :user_uid, :client_service_uid, :expires_at, :reference, :attempts],
    type: :set

  @doc """
  A verification code changeset for 2 factor authentication.
  This will generate a random reference and set an expired date.

  """
  def create_changeset(%User{uid: user_uid}, %ClientService{uid: client_service_uid}, reference) do
    case validate_reference(reference, client_service_uid) do
      :ok ->
        %__MODULE__{
          code: generate_code(),
          user_uid: user_uid,
          client_service_uid: client_service_uid,
          expires_at: expires_at(),
          reference: reference,
          attempts: 0
        }

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Will return verification failed when the 3rd attempt is raised.
  """
  def handle_attempts(reference, user_uid, client_service_uid) do
    query = [
      {:==, :user_uid, user_uid},
      {:==, :client_service_uid, client_service_uid},
      {:==, :reference, reference}
    ]

    case MementoRepo.get(__MODULE__, query) do
      {:ok, [verification_code]} -> increment_attempts(verification_code)
      _ -> {:error, "verification failed"}
    end
  end

  defp increment_attempts(%__MODULE__{attempts: attempts} = verification_code)
       when attempts < @max_attempts - 1 do
    Map.put(verification_code, :attempts, attempts + 1)
    |> MementoRepo.insert()

    {:error, "verification failed"}
  end

  defp increment_attempts(%__MODULE__{} = verification_code) do
    MementoRepo.delete(verification_code)
    {:error, "max attempts reached"}
  end

  defp increment_attempts(_verification_code), do: {:error, "verification failed"}

  def max_age, do: @max_age

  defp expires_at do
    DateTime.utc_now()
    |> DateTime.add(@max_age, :second)
    |> DateTime.to_unix()
  end

  defp validate_reference(reference, client_service_uid) do
    with true <- valid_reference?(reference),
         true <- unique_reference?(reference, client_service_uid) do
      :ok
    else
      {:error, message} -> {:error, message}
    end
  end

  defp valid_reference?(reference) do
    length = String.length(reference)

    case length > 21 and length < 45 do
      true -> true
      false -> {:error, "invalid reference should be between 22 and 44 characters"}
    end
  end

  @doc """
  Validates that the verification reference is unique.
  """
  def unique_reference?(reference, client_service_uid) do
    query = [
      {:==, :client_service_uid, client_service_uid},
      {:==, :reference, reference}
    ]

    case MementoRepo.get(__MODULE__, query) do
      {:ok, []} -> true
      {:ok, _} -> {:error, "reference must be unique"}
      _ -> {:error, :unknown_verification_code_failure}
    end
  end

  defp generate_code do
    Enum.random(1_000..9_999)
  end
end
