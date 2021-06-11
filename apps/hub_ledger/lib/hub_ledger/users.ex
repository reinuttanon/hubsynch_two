defmodule HubLedger.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias HubLedger.Repo

  alias HubLedger.Users.{AccessRequest, User, UserNotifier}

  @hub_identity_user Application.get_env(:hub_ledger, :hub_identity_user)
  @hub_identity Application.get_env(:hub_ledger, :hub_identity)

  # In future if this has a failure we should notify the logs
  def create_access_request_and_notify(user_email, hub_identity_uid, url_fun) do
    {:ok, access_request} = create_access_request(%{hub_identity_uid: hub_identity_uid})
    UserNotifier.deliver_confirmation_to_all_admins(user_email, url_fun.(access_request.id))
  end

  def deliver_access_notification(access_request_id, user_id, url) do
    with %User{id: id, role: "admin", hub_identity_uid: hub_identity_uid} <- get_user!(user_id),
         %AccessRequest{approved_at: nil} = access_request <-
           get_access_request(%{id: access_request_id}),
         {:ok, _response} <- user_confirm_multi(access_request, id),
         {:ok, %{"emails" => [%{"address" => user_email}]}} <-
           @hub_identity_user.get(%{uid: hub_identity_uid}) do
      UserNotifier.deliver_access_notification(user_email, url)
    else
      %AccessRequest{} -> {:error, "Request has been approved"}
      %User{} -> {:error, "Only admins can approve access requests"}
      _ -> {:error, "User Confirmation failure"}
    end
  end

  defp user_confirm_multi(
         %AccessRequest{hub_identity_uid: hub_identity_uid} = access_request,
         approver_id
       ) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :access_request,
      AccessRequest.update_changeset(access_request, %{approver_id: approver_id})
    )
    |> Ecto.Multi.insert(
      :user,
      User.create_changeset(%User{}, %{hub_identity_uid: hub_identity_uid})
    )
    |> Repo.transaction()
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Returns the list of users filter by role.

  ## Examples

      iex> list_users("admin")
      [%User{role: "admin"}, ...]

  """
  def list_users(%{role: role}) do
    query =
      from u in User,
        where: u.role == ^role

    Repo.all(query)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user(%{hub_identity_uid: hub_identity_uid}) do
    query =
      from u in User,
        where: u.hub_identity_uid == ^hub_identity_uid

    Repo.one(query)
  end

  def get_user(%{user_token: user_token}) do
    @hub_identity.get_current_user(user_token)
    |> get_system_user()
  end

  defp get_system_user({:ok, %{"email" => user_email, "uid" => hub_identity_uid}}) do
    case get_user(%{hub_identity_uid: hub_identity_uid}) do
      %User{} = user -> {:ok, user}
      _ -> {:error, user_email, hub_identity_uid}
    end
  end

  defp get_system_user({:error, message}), do: {:error, message}

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  def create_admin_user(attrs \\ %{}) do
    %User{}
    |> User.create_admin_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    user
    |> User.delete_changeset()
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.update_changeset(user, attrs)
  end

  alias HubLedger.Users.AccessRequest

  @doc """
  Returns the list of access_requests.

  ## Examples

      iex> list_access_requests()
      [%AccessRequest{}, ...]

  """
  def list_access_requests do
    Repo.all(AccessRequest)
  end

  @doc """
  Gets a single access_request.

  Raises `Ecto.NoResultsError` if the Access request does not exist.

  ## Examples

      iex> get_access_request!(123)
      %AccessRequest{}

      iex> get_access_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_access_request!(id), do: Repo.get!(AccessRequest, id)

  def get_access_request(%{id: id}) do
    query =
      from ar in AccessRequest,
        where: ar.id == ^id

    Repo.one(query)
  end

  def get_pending_access_request(%{id: id}) do
    query =
      from ar in AccessRequest,
        where: ar.id == ^id

    Repo.one(query)
  end

  def get_access_request(%{hub_identity_uid: hub_identity_uid}) do
    query =
      from ar in AccessRequest,
        where: ar.hub_identity_uid == ^hub_identity_uid

    Repo.one(query)
  end

  @doc """
  Creates a access_request.

  ## Examples

      iex> create_access_request(%{field: value})
      {:ok, %AccessRequest{}}

      iex> create_access_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_access_request(attrs \\ %{}) do
    %AccessRequest{}
    |> AccessRequest.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a access_request.

  ## Examples

      iex> update_access_request(access_request, %{field: new_value})
      {:ok, %AccessRequest{}}

      iex> update_access_request(access_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_access_request(%AccessRequest{} = access_request, attrs) do
    access_request
    |> AccessRequest.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a access_request.

  ## Examples

      iex> delete_access_request(access_request)
      {:ok, %AccessRequest{}}

      iex> delete_access_request(access_request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_access_request(%AccessRequest{approved_at: nil} = access_request) do
    Repo.delete(access_request)
  end

  def delete_access_request(_), do: {:error, "Cannot delete approved access request"}

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking access_request changes.

  ## Examples

      iex> change_access_request(access_request)
      %Ecto.Changeset{data: %AccessRequest{}}

  """
  def change_access_request(%AccessRequest{} = access_request, attrs \\ %{}) do
    AccessRequest.update_changeset(access_request, attrs)
  end
end
