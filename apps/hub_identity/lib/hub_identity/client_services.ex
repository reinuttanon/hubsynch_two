defmodule HubIdentity.ClientServices do
  @moduledoc """
  The ClientServices context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias HubIdentity.Administration.Administrator
  alias HubIdentity.ClientServices.{ApiKey, ClientService, StateSecret}
  alias HubCluster.MementoRepo
  alias HubIdentity.Repo

  @doc """
  Returns the list of client_services.

  ## Examples

      iex> list_client_services()
      [%ClientService{}, ...]

  """
  def list_client_services do
    Repo.all_present(ClientService)
  end

  def list_client_services(%{administrator_id: administrator_id, ids: true}) do
    query =
      from c in ClientService,
        join: acs in "administrators_client_services",
        on: c.id == acs.client_service_id,
        where: acs.administrator_id == ^administrator_id,
        select: c.id

    Repo.all_present(query)
  end

  def list_client_services(%{administrator_id: administrator_id, uids: true}) do
    query =
      from c in ClientService,
        join: acs in "administrators_client_services",
        on: c.id == acs.client_service_id,
        where: acs.administrator_id == ^administrator_id,
        select: c.uid

    Repo.all_present(query)
  end

  def list_client_services(%{administrator_id: administrator_id}) do
    query =
      from c in ClientService,
        join: acs in "administrators_client_services",
        on: c.id == acs.client_service_id,
        where: acs.administrator_id == ^administrator_id

    Repo.all_present(query)
  end

  def list_client_services(%{ids: true}) do
    query =
      from c in ClientService,
        select: c.id

    Repo.all_present(query)
  end

  @doc """
  Gets a single client_service.

  Raises `Ecto.NoResultsError` if the Client service does not exist.

  ## Examples

      iex> get_client_service!(123)
      %ClientService{}

      iex> get_client_service!(456)
      ** (Ecto.NoResultsError)

  """
  def get_client_service!(id) do
    api_key_query = from a in ApiKey, where: is_nil(a.deleted_at)

    query =
      from a in ClientService,
        where: a.id == ^id,
        preload: [:administrators, api_keys: ^api_key_query]

    Repo.one_present!(query)
  end

  @doc """
  Creates a client_service.

  ## Examples

    iex> create_client_service(%{field: value})
    {:ok, %ClientService{}}

    iex> create_client_service(%{field: bad_value})
    {:error, %Ecto.Changeset{}}
  """

  # def create_client_service(attrs \\ %{}) do
  #   case multi_client_service_and_api_keys(attrs) do
  #     {:ok, %{client_service: client_service}} -> {:ok, client_service}
  #     {:error, :client_service, changeset, %{}} -> {:error, changeset}
  #     return -> return
  #   end
  # end

  def create_client_service(attrs, %Administrator{} = administrator) do
    case multi_client_service_and_api_keys(attrs, administrator) do
      {:ok, %{client_service: client_service}} -> {:ok, client_service}
      {:error, :client_service, changeset, %{}} -> {:error, changeset}
      return -> return
    end
  end

  @doc """
  Updates a client_service.

  ## Examples

      iex> update_client_service(client_service, %{field: new_value})
      {:ok, %ClientService{}}

      iex> update_client_service(client_service, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_client_service(%ClientService{} = client_service, attrs) do
    client_service
    |> ClientService.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Add an administrator to a client_service.

  ## Examples

      iex> add_administrator(client_service, administrator)
      {:ok, %ClientService{}}

      iex> add_administrator(client_service, administrator)
      {:error, %Ecto.Changeset{}}

  """
  def add_administrator(%ClientService{} = client_service, %Administrator{} = administrator) do
    client_service = Repo.preload(client_service, [:administrators, :api_keys])

    client_service
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:administrators, [administrator | client_service.administrators])
    |> Repo.update()
  end

  @doc """
  Remove an administrator from a client_service.

  ## Examples

      iex> remove_administrator(client_service, administrator)
      {:ok, %ClientService{}}

      iex> remove_administrator(client_service, administrator)
      {:error, %Ecto.Changeset{}}

  """
  def remove_administrator(
        %ClientService{} = client_service,
        %Administrator{id: administrator_id}
      ) do
    client_service = Repo.preload(client_service, [:administrators, :api_keys])

    new_administrators =
      Enum.filter(client_service.administrators, fn administrator ->
        administrator.id != administrator_id
      end)

    client_service
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:administrators, new_administrators)
    |> Repo.update()
  end

  @doc """
  Deletes a client_service.

  ## Examples

      iex> delete_client_service(client_service)
      {:ok, %ClientService{}}

      iex> delete_client_service(client_service)
      {:error, %Ecto.Changeset{}}

  """
  def delete_client_service(%ClientService{id: id} = client_service) do
    now = DateTime.utc_now()

    Multi.new()
    |> Multi.update(:client_service, ClientService.delete_changeset(client_service))
    |> Multi.update_all(
      :api_keys,
      fn %{} ->
        from(a in ApiKey,
          where: a.client_service_id == ^id,
          where: is_nil(a.deleted_at),
          update: [set: [deleted_at: ^now]]
        )
      end,
      []
    )
    |> Repo.transaction()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking client_service changes.

  ## Examples

      iex> change_client_service(client_service)
      %Ecto.Changeset{data: %ClientService{}}

  """
  def change_client_service(%ClientService{} = client_service, attrs \\ %{}) do
    ClientService.update_changeset(client_service, attrs)
  end

  def new_client_service(%ClientService{} = client_service, attrs, administrator) do
    ClientService.new_changeset(client_service, attrs, administrator)
  end

  @doc """
  Returns the list of api_keys.

  ## Examples

      iex> list_api_keys()
      [%ApiKey{}, ...]

  """
  def list_api_keys do
    Repo.all_present(ApiKey)
  end

  @doc """
  Gets a single api_key.

  Raises `Ecto.NoResultsError` if the Api key does not exist.

  ## Examples

      iex> get_api_key!(123)
      %ApiKey{}

      iex> get_api_key!(456)
      ** (Ecto.NoResultsError)

  """
  def get_api_key!(id) do
    query =
      from a in ApiKey,
        where: a.id == ^id

    Repo.one_present!(query)
  end

  def get_api_key_by_data(data) do
    query =
      from a in ApiKey,
        where: a.data == ^data,
        preload: [:client_service]

    Repo.one_present(query)
  end

  @doc """
  Creates a api_key.

  ## Examples

      iex> create_api_key(%{field: value})
      {:ok, %ApiKey{}}

      iex> create_api_key(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_api_key(attrs \\ %{}) do
    %ApiKey{}
    |> ApiKey.changeset(attrs)
    |> Repo.insert()
  end

  def roll_api_keys(%ClientService{id: id}) do
    now = DateTime.utc_now()

    Multi.new()
    |> Multi.update_all(
      :old_api_keys,
      fn %{} ->
        from(a in ApiKey,
          where: a.client_service_id == ^id,
          where: is_nil(a.deleted_at),
          update: [set: [deleted_at: ^now]]
        )
      end,
      []
    )
    |> Multi.insert(:private_key, fn %{} ->
      ApiKey.changeset(%ApiKey{}, %{client_service_id: id, type: "private"})
    end)
    |> Multi.insert(:public_key, fn %{} ->
      ApiKey.changeset(%ApiKey{}, %{client_service_id: id, type: "public"})
    end)
    |> Repo.transaction()
  end

  @doc """
  Deletes a api_key.

  ## Examples

      iex> delete_api_key(api_key)
      {:ok, %ApiKey{}}

      iex> delete_api_key(api_key)
      {:error, %Ecto.Changeset{}}

  """
  def delete_api_key(%ApiKey{} = api_key) do
    api_key
    |> ApiKey.delete_changeset()
    |> Repo.update()
  end

  def create_state_secret!(%ClientService{} = client_service) do
    client_service
    |> StateSecret.create_changeset()
    |> MementoRepo.insert!()
  end

  def create_state_secret!(_), do: {:error, :invalid_client_service}

  def withdraw_state_secret(secret) do
    case MementoRepo.withdraw(StateSecret, {:==, :secret, secret}) do
      {:ok, %StateSecret{} = secret} -> secret
      {:error, message} -> {:error, message}
    end
  end

  defp multi_client_service_and_api_keys(attrs, administrator) do
    Multi.new()
    |> Multi.insert(
      :client_service,
      ClientService.new_changeset(%ClientService{}, attrs, administrator)
    )
    |> Multi.insert(:private_key, fn %{client_service: client_service} ->
      ApiKey.changeset(%ApiKey{}, %{client_service_id: client_service.id, type: "private"})
    end)
    |> Multi.insert(:public_key, fn %{client_service: client_service} ->
      ApiKey.changeset(%ApiKey{}, %{client_service_id: client_service.id, type: "public"})
    end)
    |> Repo.transaction()
  end
end
