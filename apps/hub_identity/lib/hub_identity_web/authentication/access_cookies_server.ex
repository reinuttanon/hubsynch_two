defmodule HubIdentityWeb.Authentication.AccessCookiesServer do
  @moduledoc false
  use GenServer
  alias HubIdentity.Identities.{CurrentUser, Email, User}
  alias HubIdentity.MementoRepo
  alias HubIdentityWeb.Authentication.AccessCookie

  # Max age in miliseconds
  @expiration AccessCookie.max_age() * 1000

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    HubIdentity.MementoRepo.create_table(AccessCookie)
    {:ok, %{}}
  end

  def create_cookie(resource, provider \\ "HubIdentity")

  def create_cookie(%User{} = user, provider) do
    owner = CurrentUser.build(user, provider)
    GenServer.call(__MODULE__, {:create_cookie, owner})
  end

  def create_cookie(%{address: address, user: user}, provider) do
    owner = CurrentUser.build(user, address, provider)
    GenServer.call(__MODULE__, {:create_cookie, owner})
  end

  def create_cookie(%{user: user, email: %Email{address: address}}, provider) do
    owner = CurrentUser.build(user, address, provider)
    GenServer.call(__MODULE__, {:create_cookie, owner})
  end

  def create_cookie(_resource, _provider), do: {:error, :unknown_cookie_type}

  def delete_cookies(%{uid: uid}) do
    GenServer.call(__MODULE__, {:delete_cookies, uid})
    :ok
  end

  def get_cookie(id) do
    GenServer.call(__MODULE__, {:get_cookie, id})
  end

  def get_cookies(%{uid: uid}) do
    GenServer.call(__MODULE__, {:get_cookies, %{uid: uid}})
  end

  def list_cookies do
    GenServer.call(__MODULE__, :list_cookies)
  end

  def withdraw_cookie(id) do
    GenServer.call(__MODULE__, {:withdraw_cookie, id})
  end

  def handle_call({:create_cookie, user}, _from, state) do
    expires_at =
      DateTime.utc_now()
      |> DateTime.add(@expiration, :millisecond)
      |> DateTime.to_unix()

    {:ok, %AccessCookie{id: id} = cookie} =
      AccessCookie.create_changeset(user, expires_at)
      |> MementoRepo.insert()

    {:ok, _reference} = :timer.send_after(@expiration, {:expire, id})
    {:reply, {:ok, cookie}, state}
  end

  def handle_call({:delete_cookies, uid}, _from, state) do
    Memento.transaction!(fn ->
      case Memento.Query.select_raw(AccessCookie, get_cookies_by_uid_query(uid)) do
        [] ->
          nil

        cookies when is_list(cookies) ->
          Enum.each(cookies, fn cookie -> Memento.Query.delete_record(cookie) end)

        _ ->
          nil
      end
    end)

    {:reply, :ok, state}
  end

  def handle_call({:get_cookies, %{uid: uid}}, _from, state) do
    results =
      Memento.transaction!(fn ->
        Memento.Query.select_raw(AccessCookie, get_cookies_by_uid_query(uid))
      end)

    {:reply, results, state}
  end

  def handle_call({:get_cookie, id}, _from, state) do
    cookie = MementoRepo.get_one(AccessCookie, id)
    {:reply, cookie, state}
  end

  def handle_call(:list_cookies, _from, state) do
    cookies = MementoRepo.all(AccessCookie)
    {:reply, cookies, state}
  end

  def handle_call({:withdraw_cookie, id}, _from, state) do
    id = MementoRepo.withdraw(AccessCookie, id)
    {:reply, id, state}
  end

  def handle_info({:expire, id}, state) do
    MementoRepo.withdraw(AccessCookie, id)
    {:noreply, state}
  end

  defp get_cookies_by_uid_query(uid) do
    match_head = {AccessCookie, :"$1", %{uid: uid}, :"$3"}
    result = [:"$_"]
    [{match_head, [], result}]
  end
end
