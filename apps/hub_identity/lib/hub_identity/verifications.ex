defmodule HubIdentity.Verifications do
  @moduledoc """
  2 Factor Authentication context.
  """

  alias HubIdentity.ClientServices.ClientService
  alias HubIdentity.Identities.User
  alias HubIdentity.MementoRepo
  alias HubIdentity.Identities

  alias HubIdentity.Verifications.{
    EmailVerifyReference,
    EmailVerifyReferenceServer,
    VerificationCode,
    VerificationCodeServer
  }

  @doc """
  Creates and return a EmailVerifyReference.

  ## Examples
    iex> create_email_verify_reference(%{
          address: address,
          password: password,
          password_confirmation: password_confirmation
        },%ClientService{redirect_url: redirect_url, uid: client_service_uid}
      )
    {:reply, {:ok, reference}, state}

    iex> create_email_verify_reference(%{
          address: address,
          password: password
        }, %ClientService{redirect_url: redirect_url, uid: client_service_uid
      })
    iex> {:reply, {:ok, reference}, state}
    create_email_verify_reference(%{
          address: address,
          provider_info: provider_info
        }, %ClientService{redirect_url: redirect_url, uid: client_service_uid
      })
    {:reply, {:ok, reference}, state}
    iex> create_email_verify_reference(%{
          address: address,
          user: user
        }, %ClientService{redirect_url: redirect_url, uid: client_service_uid
      })
    {:reply, {:ok, reference}, state}
  """
  def create_email_verify_reference(
        %{
          address: address,
          password: password,
          password_confirmation: password_confirmation
        },
        %ClientService{redirect_url: redirect_url, uid: client_service_uid}
      ) do
    with {:ok, email} <- Identities.verify_address(address),
         {:ok, user} <-
           Identities.web_registration_changeset(%{
             password: password,
             password_confirmation: password_confirmation
           }) do
      attrs = %{
        address: email.changes.address,
        client_service_uid: client_service_uid,
        redirect_url: redirect_url,
        user: user
      }

      EmailVerifyReferenceServer.create_reference(attrs)
    end
  end

  def create_email_verify_reference(%{address: address, password: password}, %ClientService{
        redirect_url: redirect_url,
        uid: client_service_uid
      }) do
    with {:ok, email} <- Identities.verify_address(address),
         {:ok, user} <- Identities.user_registration_changeset(%{password: password}) do
      attrs = %{
        address: email.changes.address,
        client_service_uid: client_service_uid,
        redirect_url: redirect_url,
        user: user
      }

      EmailVerifyReferenceServer.create_reference(attrs)
    end
  end

  def create_email_verify_reference(
        %{address: address, provider_info: provider_info},
        %ClientService{redirect_url: redirect_url, uid: client_service_uid}
      ) do
    with {:ok, email} <- Identities.verify_address(address) do
      attrs = %{
        address: email.changes.address,
        client_service_uid: client_service_uid,
        provider_info: provider_info,
        redirect_url: redirect_url
      }

      EmailVerifyReferenceServer.create_reference(attrs)
    end
  end

  def create_email_verify_reference(%{address: address, user: user}, %ClientService{
        redirect_url: redirect_url,
        uid: client_service_uid
      }) do
    with {:ok, email} <- Identities.verify_address(address) do
      attrs = %{
        address: email.changes.address,
        client_service_uid: client_service_uid,
        user: user,
        redirect_url: redirect_url
      }

      EmailVerifyReferenceServer.create_reference(attrs)
    end
  end

  @doc """
  Deletes an VerificationCode.

  ## Examples
    iex> delete_code(%User{uid: user_uid}, %ClientService{uid: client_service_uid}, reference)
    :ok
  """
  def delete_code(%User{uid: user_uid}, %ClientService{uid: client_service_uid}, reference) do
    query = [
      {:==, :user_uid, user_uid},
      {:==, :client_service_uid, client_service_uid},
      {:==, :reference, reference}
    ]

    MementoRepo.withdraw(VerificationCode, query)
    :ok
  end

  @doc """
  Withdraw an EmailVerifyReference.

  ## Examples
    iex> withdraw_verify_email_reference(valid_reference)
    {:ok, email_verify_reference}

    iex> withdraw_verify_email_reference(invalid_reference)
    {:error, message}
  """
  def withdraw_verify_email_reference(reference) do
    case MementoRepo.withdraw(EmailVerifyReference, [{:==, :reference, reference}]) do
      {:ok,
       %EmailVerifyReference{provider_info: %{email_verified: false}} = email_verify_reference} ->
        {:ok, confirm_email(email_verify_reference)}

      {:ok, email_verify_reference} ->
        {:ok, email_verify_reference}

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Generates a random code and sends it to the users primary email address.

  ## Examples
    iex> generate_code(user, client_service, reference)
    :ok

    iex> generate_code(invalid_user, invalid_client_service, invalid_reference)
    {:error, message}
  """
  def generate_code(user, client_service, reference) do
    VerificationCodeServer.generate_code(user, client_service, reference)
  end

  @doc """
  Validates the code until it reaches the maximum attempts.

  ## Examples
    iex> validate_code(code, user, client_service, reference)
    {:ok, email_verify_reference}

    iex> validate_code(code, user, client_service, reference)
    {:error, "verification failed"}

    iex> validate_code(code, user, client_service, reference)
    {:error, "max attempts reached"}
  """
  def validate_code(code, user, client_service, reference) do
    query = [
      {:==, :user_uid, user.uid},
      {:==, :code, code},
      {:==, :client_service_uid, client_service.uid},
      {:==, :reference, reference}
    ]

    case MementoRepo.withdraw(VerificationCode, query) do
      {:ok, %VerificationCode{}} -> {:ok, "verification success"}
      _ -> VerificationCode.handle_attempts(reference, user.uid, client_service.uid)
    end
  end

  defp confirm_email(%EmailVerifyReference{provider_info: provider_info} = email_verify_reference) do
    new_provider_info = Map.put(provider_info, :email_verified, true)
    Map.put(email_verify_reference, :provider_info, new_provider_info)
  end
end
