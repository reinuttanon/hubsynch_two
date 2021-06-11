defmodule HubIdentity.Metrics do
  @moduledoc """
  The Metrics context.

  Metrics are designed to record various activities in the system. Currently
  these records are generated asynchronously and saved into the database.
  The intentions are to move this data into a more suitable system such as an
  elasticsearch server.

  Metrics are created under the following conditions:
  ### Record creation
  - creating a new User with Hubidentity registration or from a new Open Authentication
  - creating a new Email is confirmed (not with an Identity)
  - creating a new Identity

  ### Authentication
  - User authenticates and access_token generated
  - User authenticates and user_token generated
  - User redirected (user_token cookie is present)

  ### Data Deletion
  - delete Identity -> When a request comes from Facebook does not record a client service
  - delete User
  """

  import Ecto.Query, warn: false

  alias HubIdentity.Metrics.{MetricServer, UserActivity}
  alias HubIdentity.Repo

  def create_activities(conn, create_map, client_service_uid, provider \\ "self")

  def create_activities(
        conn,
        %{user: user, email: email, identity: identity},
        client_service_uid,
        provider
      ) do
    MetricServer.create_resource_activity(conn, %{
      owner: user,
      client_service_uid: client_service_uid,
      provider: provider
    })

    MetricServer.create_resource_activity(conn, %{
      owner: email,
      client_service_uid: client_service_uid,
      provider: provider
    })

    MetricServer.create_resource_activity(conn, %{
      owner: identity,
      client_service_uid: client_service_uid,
      provider: provider
    })

    conn
  end

  def create_activities(
        conn,
        %{user: user, email: email},
        client_service_uid,
        provider
      ) do
    MetricServer.create_resource_activity(conn, %{
      owner: user,
      client_service_uid: client_service_uid,
      provider: provider
    })

    MetricServer.create_resource_activity(conn, %{
      owner: email,
      client_service_uid: client_service_uid,
      provider: provider
    })

    conn
  end

  def create_activities(
        conn,
        %{user: _user, identity: identity},
        client_service_uid,
        provider
      ) do
    MetricServer.create_resource_activity(conn, %{
      owner: identity,
      client_service_uid: client_service_uid,
      provider: provider
    })

    conn
  end

  def create_activities(
        conn,
        %{email: email},
        client_service_uid,
        provider
      ) do
    MetricServer.create_resource_activity(conn, %{
      owner: email,
      client_service_uid: client_service_uid,
      provider: provider
    })

    conn
  end

  def create_activities(conn, _create_map, _client_service_uid, _provider), do: conn

  @doc """
  Creates a cookie activity when a access cookie is created.

  ## Examples

      iex> cookie_activity(conn, user, "client_service_uid")
      conn
  """
  def cookie_activity(conn, user, client_service_uid, type \\ "AccessCookie.create")

  def cookie_activity(conn, %{owner: user}, client_service_uid, type) do
    MetricServer.create_authenticate_activity(conn, %{
      owner_uid: user.uid,
      owner_type: "User",
      client_service_uid: client_service_uid,
      provider: "self",
      type: type
    })

    conn
  end

  def cookie_activity(conn, user, client_service_uid, type) do
    MetricServer.create_authenticate_activity(conn, %{
      owner_uid: user.uid,
      owner_type: "User",
      client_service_uid: client_service_uid,
      provider: "self",
      type: type
    })

    conn
  end

  @doc """
  WARNING: Doesn't delete the activity.
  Creates a delete activity when a user is deleted.

  ## Examples

      iex> delete_activity(conn, owner, "client_service_uid")
      conn

      iex> delete_activity(conn, owner, "facebook")
      {:ok, %UserActivity{type: User.delete}}
  """
  def delete_activity(conn, owner, client_service_uid, provider \\ "self") do
    MetricServer.delete_resource_activity(conn, %{
      owner: owner,
      client_service_uid: client_service_uid,
      provider: provider
    })

    conn
  end

  def delete_activity(owner, provider) do
    MetricServer.delete_resource_activity(%{
      owner: owner,
      provider: provider
    })
  end

  @doc """
  Creates a token_activity after the AccessToken is created.

  ## Examples

      iex> token_activity(conn, user, "client_service_uid")
      conn
  """
  def token_activity(conn, user, client_service_uid) do
    MetricServer.create_authenticate_activity(conn, %{
      owner_uid: user.uid,
      owner_type: "User",
      client_service_uid: client_service_uid,
      provider: "self",
      type: "AccessToken.create"
    })

    conn
  end

  @doc """
  Creates a verification_activity after a successful authentication.

  ## Examples

      iex> verification_activity(conn, user, "client_service_uid")
      conn

  """
  def verification_activity(conn, user, client_service_uid) do
    MetricServer.create_authenticate_activity(conn, %{
      owner_uid: user.uid,
      owner_type: "User",
      client_service_uid: client_service_uid,
      provider: "self",
      type: "Verification.success"
    })

    conn
  end

  @doc """
  Returns the list of user_activities.

  ## Examples

      iex> list_user_activities()
      [%UserActivity{}, ...]

  """
  def list_user_activities do
    Repo.all(UserActivity)
  end

  def list_user_activities(client_service_uid) do
    query =
      from u in UserActivity,
        where: u.client_service_uid == ^client_service_uid,
        group_by: u.type

    Repo.all(query)
  end

  @doc """
  Gets a single user_activity.

  Raises `Ecto.NoResultsError` if the User activity does not exist.

  ## Examples

      iex> get_user_activity!(123)
      %UserActivity{}

      iex> get_user_activity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_activity!(id), do: Repo.get!(UserActivity, id)

  def get_user_activity(%{uid: uid, type: type}) do
    query =
      from u in UserActivity,
        where: u.uid == ^uid,
        where: u.type == ^type

    Repo.one(query)
  end

  @doc """
  Creates a user_activity.

  ## Examples

      iex> create_user_activity(%{field: value})
      {:ok, %UserActivity{}}

      iex> create_user_activity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_activity(attrs \\ %{}) do
    %UserActivity{}
    |> UserActivity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  total_activities/2 Returns the count of user_activity filter by provider and user activity type.
  total_activities/3 Returns the count of user_activity filter by provider, client service and user activity type.
  ## Examples

      iex> total_activities("facebook", "User.create")
      12

      iex> total_activities("facebook","client_service_uid" ,"User.create")
      10
  """
  def total_activities(provider, %{type: type}) do
    query =
      from u in UserActivity,
        where: u.provider == ^provider,
        where: u.type == ^type

    Repo.aggregate(query, :count, :id)
  end

  @spec total_activities(any, any, %{:type => any, optional(any) => any}) :: any
  def total_activities(_provider, [], %{type: _type}), do: 0

  def total_activities(provider, client_service_uids, %{type: type}) do
    query =
      from u in UserActivity,
        where: u.client_service_uid in ^client_service_uids,
        where: u.provider == ^provider,
        where: u.type == ^type

    Repo.aggregate(query, :count, :id)
  end
end
