defmodule HubCrm.Hubsynch do
  @moduledoc """
  The Hubsynch context.
  """

  import Ecto.Query, warn: false
  alias HubCrm.HubsynchRepo

  alias HubCrm.Hubsynch.{Address, CompanyApplication, DeliveringAddress, User, UseApp}

  @doc """
  Gets a list of CompanyApplications.

  ## Examples

      iex> get_company_application({%{app_code: "this", site_id: "tochigi"}})
      {:ok, %CompanyApplication{}}

      iex> get_company_application(%{app_code: "not", site_id: "here"})
      {:error, (Ecto.NoResultsError)}

  """
  def get_company_applications(params) do
    params
    |> company_application_query()
    |> HubsynchRepo.all()
  end

  @doc """
  Determine if a CompanyApplication exists.

  ## Examples

      iex> valid_application?({%{app_code: "this", site_id: "tochigi"}})
      true

      iex> valid_application?(%{app_code: "not", site_id: "here"})
      false

  """
  def valid_application?(params) do
    params
    |> company_application_query()
    |> HubsynchRepo.exists?()
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    query =
      from u in User,
        where: u.delete_flag == "false" or is_nil(u.delete_flag),
        order_by: [desc: u.create_timestamp],
        limit: 10

    HubsynchRepo.all(query)
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

  def get_user(%{hashid: hashid}) do
    HubsynchRepo.get_by(User, hashid: hashid)
  end

  def get_user(id) when is_binary(id) do
    with {int_id, ""} <- Integer.parse(id) do
      get_user(int_id)
    else
      _ -> :error
    end
  end

  def get_user(id) when is_integer(id) do
    user_query(id)
    |> HubsynchRepo.one()
  end

  def get_user!(id) do
    user_query(id)
    |> HubsynchRepo.one!()
  end

  def get_user_by_email(email)
      when is_binary(email) do
    HubsynchRepo.get_by(User, email: email)
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
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    with %User{} = user <- HubsynchRepo.get_by(User, email: email),
         true <-
           User.valid_password?(user, password) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Checks if a users exists.

  ## Examples

      iex> user_exist?("sullymustycode@gmail.com")
      true

      iex> user_exist?("pickle.rick@citidel.com")
      false

  """
  def user_exists?(email) when is_binary(email) do
    query =
      from u in User,
        where: u.email == ^email

    HubsynchRepo.exists?(query)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{})

  # def create_user(%{"app_code" => app_code, "site_id" => site_id} = params) do
  #   with [%CompanyApplication{company_app_id: company_app_id} | _] <-
  #          get_company_applications(%{app_code: app_code, site_id: site_id}) do
  #     params
  #     |> Map.delete("app_code")
  #     |> Map.delete("site_id")
  #     |> Map.put("company_app_id", company_app_id)
  #     |> create_user()
  #   end
  # end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> HubsynchRepo.insert()
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
    |> HubsynchRepo.update()
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
    |> HubsynchRepo.update()
  end

  def get_addresses(%User{user_id: user_id} = user) do
    delivering_addresses = Task.async(fn -> get_delivering_addresses(user_id) end)
    address = Task.async(fn -> Address.cast(user) end)
    addresses_return(Task.await(address), Task.await(delivering_addresses))
  end

  def get_addresses(user_id) do
    delivering_addresses = Task.async(fn -> get_delivering_addresses(user_id) end)
    address = Task.async(fn -> get_address(user_id, user_id) end)
    addresses_return(Task.await(address), Task.await(delivering_addresses))
  end

  def get_address(user_id, user_id) do
    get_user(user_id)
    |> Address.cast()
  end

  def get_address(user_id, address_id) do
    with %DeliveringAddress{} = address <-
           get_delivering_address(user_id, address_id) do
      Address.cast(address)
    else
      _ -> nil
    end
  end

  def create_address(%User{user_id: user_id}, attrs) do
    with full_attrs <- Map.put(attrs, "user_id", user_id),
         %Ecto.Changeset{} = changeset <-
           DeliveringAddress.changeset(%DeliveringAddress{}, full_attrs),
         {:ok, %DeliveringAddress{} = address} <-
           HubsynchRepo.insert(changeset) do
      {:ok, Address.cast(address)}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def update_address(user_id, address_id, attrs \\ %{})

  def update_address(user_id, user_id, attrs) do
    with %User{} = user <- get_user(user_id),
         %Ecto.Changeset{} = changeset <- Address.update_changeset(user, attrs),
         {:ok, updated} <- HubsynchRepo.update(changeset) do
      {:ok, Address.cast(updated)}
    else
      nil -> {:error, "invalid address or user"}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def update_address(user_id, address_id, attrs) do
    with %DeliveringAddress{} = delivering_address <-
           get_delivering_address(user_id, address_id),
         %Ecto.Changeset{} = changeset <- Address.update_changeset(delivering_address, attrs),
         {:ok, updated} <- HubsynchRepo.update(changeset) do
      {:ok, Address.cast(updated)}
    else
      nil -> {:error, "invalid address or user"}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def preload_addresses(%User{} = user) do
    addresses = get_addresses(user)

    %{user | addresses: addresses}
  end

  def preload_addresses(nil), do: nil

  defp addresses_return(%Address{} = address, addresses), do: [address | addresses]

  defp addresses_return(nil, _), do: []

  defp get_delivering_address(user_id, address_id) do
    query =
      from da in DeliveringAddress,
        where: da.user_id == ^user_id,
        where: da.user_address_id == ^address_id

    HubsynchRepo.one(query)
  end

  defp get_delivering_addresses(user_id) do
    query =
      from da in DeliveringAddress,
        where: da.user_id == ^user_id

    HubsynchRepo.all(query)
    |> Task.async_stream(fn address -> Address.cast(address) end)
    |> Enum.map(fn {:ok, address} -> address end)
  end

  defp company_application_query(%{app_code: app_code, site_id: site_id}) do
    from ca in CompanyApplication,
      where: ca.app_code == ^app_code,
      where: ca.site_id == ^site_id,
      where: ca.delete_flag == "false" or is_nil(ca.delete_flag),
      join: ua in UseApp,
      on: ua.company_app_id == ca.company_app_id,
      where: not is_nil(ua.company_id)
  end

  defp company_application_query(_), do: :error

  defp user_query(id) do
    from u in User,
      where: u.user_id == ^id,
      where: u.delete_flag != "true"
  end
end
