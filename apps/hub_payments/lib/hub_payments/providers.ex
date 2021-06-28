defmodule HubPayments.Providers do
  @moduledoc """
  The Providers context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias HubPayments.Repo

  alias HubPayments.Providers.{Paygent, Provider, SBPS, Vault}
  alias HubPayments.Payments.Charge
  alias HubPayments.Wallets.CreditCard

  @doc """
  Returns the list of providers.

  ## Examples

      iex> list_providers()
      [%Provider{}, ...]

  """
  def list_providers do
    Repo.all(Provider)
  end

  @doc """
  Gets a single provider.

  Raises `Ecto.NoResultsError` if the Provider does not exist.

  ## Examples

      iex> get_provider!(123)
      %Provider{}

      iex> get_provider!(456)
      ** (Ecto.NoResultsError)

  """
  def get_provider!(id), do: Repo.get!(Provider, id)

  def get_provider(%{name: name}) do
    query =
      from p in Provider,
        where: p.name == ^name

    Repo.one(query)
  end

  @doc """
  Creates a provider.

  ## Examples

      iex> create_provider(%{field: value})
      {:ok, %Provider{}}

      iex> create_provider(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_provider(attrs \\ %{}) do
    %Provider{}
    |> Provider.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a provider.

  ## Examples

      iex> update_provider(provider, %{field: new_value})
      {:ok, %Provider{}}

      iex> update_provider(provider, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_provider(%Provider{} = provider, attrs) do
    provider
    |> Provider.update_changeset(attrs)
    |> Repo.update()
  end

  def process_charge(
        %Provider{} = provider,
        %Charge{} = charge,
        %CreditCard{} = credit_card,
        token_uuid \\ nil
      ) do
    process_authorization(provider, charge, credit_card, token_uuid)
    |> process_capture(provider, charge)
  end

  def process_charge(
        %Provider{} = provider,
        %Charge{} = charge,
        %CreditCard{} = credit_card,
        cvv,
        token_uuid
      ) do
    process_authorization(provider, charge, credit_card, cvv, token_uuid)
    |> process_capture(provider, charge)
  end

  def process_authorization(
        %Provider{id: id, name: "paygent"},
        %Charge{uuid: charge_uuid} = charge,
        %CreditCard{} = credit_card,
        token_uid
      ) do
    with %{"provider" => "paygent"} = request <-
           Paygent.MessageBuilder.build_authorization(charge, credit_card, token_uid),
         {:ok, request_json} <- Jason.encode(request),
         {:ok, message} <-
           create_message(%{
             provider_id: id,
             request: request_json,
             type: "authorization",
             owner: %{object: "HubPayments.Charge", uid: charge_uuid}
           }),
         {:ok, response, data} <- Vault.authorize(request, "paygent") do
      update_message(message, %{response: response, data: data})
    end
  end

  def process_authorization(
        %Provider{id: id, name: "sbps"},
        %Charge{uuid: charge_uuid} = charge,
        %CreditCard{} = credit_card,
        cvv,
        token_uid
      ) do
    with %{"provider" => "sbps"} = request <-
           SBPS.MessageBuilder.build_authorization(charge, credit_card, token_uid, cvv),
         {:ok, request_json} <- Jason.encode(request),
         {:ok, message} <-
           create_message(%{
             provider_id: id,
             request: request_json,
             type: "authorization",
             owner: %{object: "HubPayments.Charge", uid: charge_uuid}
           }),
         {:ok, response, data} <- Vault.authorize(request, "sbps") do
      update_message(message, %{response: response, data: data})
    end
  end

  # def process_capture(charge, %Provider{id: id, name: "paygent"}, message) do
  def process_capture({:ok, message}, %Provider{id: id, name: "sbps"} = provider, _charge) do
    with {:ok, request_body} <- SBPS.MessageBuilder.build_capture(message),
         {:ok, capture_message} <-
           create_message(%{
             provider_id: id,
             request: request_body,
             type: "capture",
             owner: %{
               object: message.owner.object,
               uid: message.owner.uid
             }
           }),
         {:ok, response, data} <- SBPS.Server.capture(request_body) do
      update_message(capture_message, %{response: response, data: data})
    end
  end

  def process_capture({:ok, message}, %Provider{id: id, name: "paygent"}, charge) do
    with {:ok, request} <- Paygent.MessageBuilder.build_capture(charge, message),
         {:ok, capture_message} <-
           create_message(%{
             provider_id: id,
             request: request,
             type: "capture",
             owner: %{
               object: message.owner.object,
               uid: message.owner.uid
             }
           }),
         {:ok, response, data} <- Paygent.Server.capture(request) do
      update_message(capture_message, %{response: response, data: data})
    end
  end

  def process_capture({:error, message}, %Provider{name: "paygent"}, %Charge{uuid: uuid})
      when is_binary(message) do
    # Logger.error("charge uuid: #{uuid} failed for Paygent with error: #{message}")
    {:error, message}
  end

  def process_capture({:error, message}, provider, charge) do
    encoded = Jason.encode!(message)
    process_capture({:error, encoded}, provider, charge)
  end

  @doc """
  Deletes a provider.

  ## Examples

      iex> delete_provider(provider)
      {:ok, %Provider{}}

      iex> delete_provider(provider)
      {:error, %Ecto.Changeset{}}

  """
  def delete_provider(%Provider{} = provider) do
    Repo.delete(provider)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking provider changes.

  ## Examples

      iex> change_provider(provider)
      %Ecto.Changeset{data: %Provider{}}

  """
  def change_provider(%Provider{} = provider, attrs \\ %{}) do
    Provider.changeset(provider, attrs)
  end

  alias HubPayments.Providers.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
