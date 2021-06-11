defmodule HubIdentity.Identities do
  @moduledoc """
  The Identities context, such as Email, User, UserToken and UserNotifier.
  """
  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias HubIdentity.Providers.ProviderConfig
  alias HubIdentity.Identities.{Email, Identity, User, UserToken, UserNotifier}
  alias HubIdentity.Metrics
  alias HubIdentity.Repo

  @doc """
  Gets a single email.

  Raises `Ecto.NoResultsError` if the Email does not exist.

  ## Examples

      iex> get_email!(123)
      %Email{}

      iex> get_email!(456)
      ** (Ecto.NoResultsError)

  """
  def get_email!(id), do: Repo.get!(Email, id)

  @doc """
  Gets a single email by address.

  ## Examples

      iex> get_email(%{address: "erin@hivelocity.co.jp"})
      %Email{}

      iex> get_email(%{address: "not@hivelocity.co.jp"})
      nil

  """

  def get_email(%{address: address}) do
    Repo.get_by(Email, address: address)
  end

  def get_email(%{user_uid: user_uid, uid: uid}) do
    query =
      from e in Email,
        where: e.uid == ^uid,
        join: u in assoc(e, :user),
        where: u.uid == ^user_uid

    Repo.one(query)
  end

  @doc """
  Verify if an email address is valid.

  ## Examples

      iex> verify_address("erin@hivelocity.co.jp")
      {:ok, %Ecto.Changeset{}}

      iex> verify_address("invalid email address")
      {:error, %Ecto.Changeset{}}
  """
  def verify_address(address) do
    changeset = Email.verify_address(%Email{}, %{address: address})

    case changeset.valid? do
      true -> {:ok, changeset}
      false -> {:error, changeset}
    end
  end

  @doc """
  Creates a confirmed email.

  ## Examples

      iex> create_confirmed_email(%{address: "erin@hivelocity.co.jp", user_id: user.id})
      {:ok, %Email{}}
  """
  def create_confirmed_email(attrs) do
    %Email{}
    |> Email.confirmed_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a email only if is not the primary email.

  ## Examples

      iex> delete_email(email)
      {:ok, %Email{}}

      iex> delete_email(%Email{primary: true})
      {:error, "Not allowed to delete primary email"}

  """
  def delete_email(%Email{primary: true}), do: {:error, "Not allowed to delete primary email"}

  def delete_email(%Email{} = email) do
    Repo.delete(email)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Options
    with preloaded: true will preload users emails

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

      iex> get_user!(123, preloaded: true)
      %User{id: 123, emails: [%Email{}, ..]}

  """
  def get_user!(id), do: Repo.get_present!(User, id)

  def get_user!(id, preload: true) do
    query =
      from u in User,
        where: u.id == ^id,
        preload: :emails

    Repo.one_present!(query)
  end

  @doc """
  Gets a single user by uid with emails preloaded.

  Returns nil if the User does not exist or has been soft deleted.

  ## Examples

      iex> get_user(%{uid: "uid_1234"})
      %User{uid: "uid_1234", emails: [%Email{}, ..]}

      iex> get_user(%{uid: "noupe"})
      nil

  """
  def get_user(%{uid: uid}) do
    query =
      from u in User,
        where: u.uid == ^uid,
        preload: :emails

    Repo.one_present(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for user regitration.

  ## Examples

      iex> change_user_password(user)
      {:ok, %Ecto.Changeset{data: %User{}}}

      iex> change_user_password(invalid_user)
      {:error, %Ecto.Changeset{}}
  """
  def user_registration_changeset(attrs) do
    changeset = User.registration_changeset(%User{}, attrs)

    case changeset.valid? do
      true -> {:ok, changeset}
      false -> {:error, changeset}
    end
  end

  def web_registration_changeset(attrs) do
    changeset = User.web_registration_changeset(%User{}, attrs)

    case changeset.valid? do
      true -> {:ok, changeset}
      false -> {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %{delete_all_emails: {deleted_emails_count, nil}, delete_all_identities: {deleted_identities_count, nil} , update: %User{}}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    changeset = User.delete_changeset(user)

    Ecto.Multi.new()
    |> handle_credentials(user)
    |> Multi.update(:update, changeset)
    |> Repo.transaction()
  end

  defp handle_credentials(multi, %User{} = user) do
    multi
    |> Multi.delete_all(:delete_all_emails, user_search(Email, user))
    |> Multi.delete_all(:delete_all_identities, user_search(Identity, user))
  end

  defp user_search(object, %User{} = user) do
    from(o in object, where: o.user_id == ^user.id)
  end

  @doc """
  Gets a single identity.

  Raises `Ecto.NoResultsError` if the Identity does not exist.

  ## Examples

      iex> get_identity!(123)
      %Identity{}

      iex> get_identity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_identity!(id), do: Repo.get!(Identity, id)

  @doc """
  Gets a single identity by provider config and reference number.

  ## Examples

      iex> get_identity(%{provider_config_id: 12, reference: "abcd123"})
      %Identity{}

      iex> get_identity(%{provider_config_id: 12, reference: "nothere"})
      nil

  """
  def get_identity(%{
        provider_config_id: provider_config_id,
        reference: reference
      }) do
    query =
      from i in Identity,
        where: i.provider_config_id == ^provider_config_id,
        where: i.reference == ^reference

    Repo.one(query)
  end

  @doc """
  Creates a identity.

  ## Examples

      iex> create_identity(%{field: value})
      {:ok, %Identity{}}

      iex> create_identity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_identity(attrs \\ %{}) do
    %Identity{}
    |> Identity.changeset(attrs)
    |> Repo.insert()

    # |> Repo.insert_with_activit)
  end

  @doc """
  Deletes a identity. This does NOT soft delete. The record will be deleted.

  ## Examples

      iex> delete_identity(identity)
      {:ok, %Identity{}}

      iex> delete_identity(identity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_identity(%Identity{} = identity) do
    Repo.delete(identity)
  end

  ### Integrated Methods ###
  @doc """
  Deletes a user activity. This does NOT soft delete. The record will be deleted. Because facebook requires it.

  ## Examples

      iex> delete_user_data(%ProviderConfig{id: id, name: name}, reference)
      {:ok, %Identity{}}

      iex> delete_user_data(%ProviderConfig{id: id, name: name}, reference)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_data(%ProviderConfig{id: id, name: name}, reference) do
    with %Identity{} = identity <- get_identity(%{provider_config_id: id, reference: reference}),
         {:ok, _} <- delete_identity(identity) do
      Metrics.delete_activity(identity, name)
    end
  end

  ## User authentiction by Identity ##

  @doc """
  The main method for authentication through a Open Auth provider.
  This method will find a user first by Identity, then by the email address from the provider.

  - If a User for the provider exists, the user will be returned
  - If a User for the provider exists, but the email is new, then a new Email will be generated for
  the User.
  - If no User exists but the email from the provider is a known Email, then the Email user will
  be used to generate a new Identity record, and the Email User will be returned.
  - If no User exists and the email from the provider is unknown, then new Identity, Email, and User
  records will be generated, and the new User will be returned.
  - If the Email provided has a different User than what is associated with the Identity, then an error
  will be returned.

  ## Examples

      iex> find_or_create_user_from_identity(params)
      {:ok, %User{}}

      iex> find_or_create_user_from_identity(params)
      {:error, :email_taken}
  """

  def find_or_create_user_from_identity(params) do
    with %User{} = user <- get_user_by_identity(params) do
      create_email_or_return_user(params, user)
    else
      nil -> create_identity_from_email(params)
    end
  end

  @doc """
  Get a User from and Identity by and Identity attributes.

  ## Examples

      iex> get_user_by_identity(params)
      %User{}

      iex> get_user_by_identity(params)
      nil
  """
  def get_user_by_identity(%{reference: reference, provider_config_id: provider_config_id}) do
    query =
      from i in Identity,
        where: i.reference == ^reference,
        where: i.provider_config_id == ^provider_config_id,
        join: u in assoc(i, :user),
        where: is_nil(u.deleted_at),
        select: u

    query
    |> Repo.one()
  end

  ## User authentiction by Email ##

  @doc """
  Gets a user by email address. This will preload a users emails.

  ## Options
    `primary: true/false` will filter for a users primary email

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{id: 12, emails: [%Email{}, ...]}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(address) when is_binary(address) do
    query =
      from e in Email,
        where: e.address == ^address

    query
    |> user_join_query()
    |> Repo.one()
    |> Repo.preload(:emails)
  end

  def get_user_by_email(address, primary: false), do: get_user_by_email(address)

  def get_user_by_email(address, primary: true) when is_binary(address) do
    query =
      from e in Email,
        where: e.address == ^address,
        where: e.primary == true

    query
    |> user_join_query()
    |> Repo.one()
    |> Repo.preload(:emails)
  end

  @doc """
  A helper method to filter though a User emails for the primary email.
  Will error if no primary email found.

  ## Examples

      iex> get_user_primary_email(%User{id: 12, emails: [%Email{}, ..]})
      %Email{}

      iex> get_user_primary_email(%User{id: 12, emails: [%Email{}, ..]})
      {:error, :primary_email_not_found}

  """
  def get_user_primary_email(%User{emails: emails}) when is_list(emails),
    do: get_primary_email(emails)

  def get_user_primary_email(%User{} = user) do
    Repo.preload(user, :emails)
    |> get_user_primary_email()
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(address, password)
      when is_binary(address) and is_binary(password) do
    with %User{} = user <- get_user_by_email(address, primary: true),
         true <- User.valid_password?(user, password) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Registers a user through the API with a valid email and valid password.

  This will return a map of a User and Email inside an :ok tuple.

  By default a registered user is a new user and the email will be set as primary.

  ## Note on errors:
  Registering a User requires a valid User and a valid Email.

  If a User is invalid the Email validations will not run, and return
  the User validation failures.

  In the event of a failed Email the attempted user will be returned along with
  the Email validation failures.

  The failed Email or User will be in the second postion of the tuple response,
  the last position will either be the attempted User or an empty map.

  ## Examples

      iex> handle_confirmation(%EctoChangeset{field: value}, %Ecto.Changeset{field: value}))
      {:ok, %{email: %Email{id: id, ..}, user: %User{id: id, ..}}}


  """
  def handle_confirmation(%{address: address, user: %Ecto.Changeset{} = user_changeset}) do
    Multi.new()
    |> Multi.insert(:user, user_changeset)
    |> Multi.insert(:email, fn %{user: user} ->
      Email.confirmed_changeset(%Email{}, %{address: address, user_id: user.id, primary: true})
    end)
    |> Repo.transaction()
  end

  def handle_confirmation(%{address: address, user: %{user_id: user_id}}) do
    with %Ecto.Changeset{valid?: true} = email_changeset <-
           Email.confirmed_changeset(%Email{}, %{address: address, user_id: user_id}),
         {:ok, email} <- Repo.insert(email_changeset) do
      {:ok, %{email: email}}
    else
      %Ecto.Changeset{valid?: false} = email_changeset -> {:error, email_changeset}
      {:error, email_changeset} -> {:error, email_changeset}
    end
  end

  def handle_confirmation(%{provider_info: provider_info}) when provider_info != nil do
    find_or_create_user_from_identity(provider_info)
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given email address.

  ## Examples

      iex> deliver_user_confirmation_instructions("erin@hivelocity.co.jp", &Routes.user_confirmation_url(conn, :confirm, &1), client_service_id)
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_confirmation_instructions(address, url) do
    UserNotifier.deliver_confirmation_instructions(address, url)
  end

  @doc """
  Change a users primary email address.

  """
  def change_user_primary_email(%Email{primary: true} = email), do: {:ok, email}

  def change_user_primary_email(%Email{user_id: user_id} = email) do
    with %User{emails: emails} <- get_user!(user_id, preload: true),
         {:ok, primary_email} <- get_primary_email(emails),
         {:ok, %{new_primary_email: new_primary_email}} <-
           update_primary_email_multi(primary_email, email),
         {:ok, _message} <-
           UserNotifier.deliver_primary_email_change_notification(primary_email) do
      {:ok, new_primary_email}
    else
      {:error, :new_primary_email, changeset, _} -> {:error, changeset}
      {:error, message} -> {:error, message}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given email.

  ## Examples

      iex> deliver_user_reset_password_instructions(email, &Routes.user_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(
        %Email{address: address, user_id: user_id},
        reset_password_url_fun,
        client_service_id
      )
      when is_function(reset_password_url_fun, 1) do
    with {encoded_token, email_token} <-
           UserToken.build_email_token(address, "reset_password", client_service_id, user_id),
         {:ok, _token} <- Repo.insert(email_token) do
      UserNotifier.deliver_reset_password_instructions(
        address,
        reset_password_url_fun.(encoded_token)
      )
    end
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         {client_service, user} <- Repo.one(query) do
      {:ok, client_service, user}
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Multi.new()
    |> Multi.update(:user, User.password_changeset(user, attrs))
    |> Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  def deliver_verification_code(email, client_service, code) do
    UserNotifier.deliver_verification_code(email, client_service, code)
  end

  ### Private Methods ###

  defp create_email_return_create_map(
         %{email: address, email_verified: true},
         %User{id: id} = user
       ) do
    with {:ok, email} <- create_confirmed_email(%{address: address, user_id: id}) do
      {:ok, %{user: user, email: email}}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp create_email_return_create_map(provider_info, user),
    do: {:verify_email, %{provider_info: provider_info, user: user}}

  defp create_identity_from_email(%{email: address} = params) do
    with %Email{user_id: user_id} <- get_email(%{address: address}),
         {:ok, identity} <- create_identity(Map.put(params, :user_id, user_id)),
         %User{} = user <- get_user!(user_id, preload: true) do
      {:ok, %{user: user, identity: identity, address: address}}
    else
      nil -> create_user_and_email_and_identity(params)
    end
  end

  defp create_email_or_return_user(%{email: address} = params, %User{id: id} = user) do
    with %Email{user_id: user_id} <- get_email(%{address: address}),
         true <- user_id == id do
      {:ok, %{user: user, address: address}}
    else
      nil -> create_email_return_create_map(params, user)
      false -> {:error, :email_taken}
    end
  end

  defp create_user_and_email_and_identity(%{email: address, email_verified: true} = params) do
    email_params = %{address: address, confirmed_at: DateTime.utc_now(), primary: true}

    Multi.new()
    |> Multi.insert(:user, User.identity_changeset())
    |> Multi.insert(:email, fn %{user: user} ->
      Email.confirmed_changeset(%Email{}, Map.put(email_params, :user_id, user.id))
    end)
    |> Multi.insert(:identity, fn %{user: user} ->
      Identity.changeset(%Identity{}, Map.put(params, :user_id, user.id))
    end)
    |> Repo.transaction()
    |> return_with_preloaded_user()
  end

  defp create_user_and_email_and_identity(params), do: {:verify_email, params}

  defp get_primary_email([%Email{primary: true} = email | _tail]), do: {:ok, email}

  defp get_primary_email([_email | tail]), do: get_primary_email(tail)

  defp get_primary_email([]), do: {:error, :primary_email_not_found}

  defp return_with_preloaded_user({:ok, %{user: user, email: email, identity: identity}}) do
    {:ok, %{user: Repo.preload(user, :emails), email: email, identity: identity}}
  end

  defp return_with_preloaded_user(error), do: error

  defp update_primary_email_multi(old_primary_email, new_primary_email) do
    Multi.new()
    |> Multi.update(
      :old_primary_email,
      Email.primary_changeset(old_primary_email, %{primary: false})
    )
    |> Multi.update(
      :new_primary_email,
      Email.primary_changeset(new_primary_email, %{primary: true})
    )
    |> Repo.transaction()
  end

  defp user_join_query(query) do
    from q in query,
      join: u in assoc(q, :user),
      where: is_nil(u.deleted_at),
      select: u
  end
end
