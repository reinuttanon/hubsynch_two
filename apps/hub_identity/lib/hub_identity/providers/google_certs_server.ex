defmodule HubIdentity.Providers.GoogleCertsServer do
  use GenServer

  require Logger

  @certs_url "https://www.googleapis.com/oauth2/v3/certs"
  @http Application.get_env(:hub_identity, :http)
  @table :google_certs

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    :ets.new(@table, [
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])

    with %{expiration: expiration, keys: keys} <- get_certs(),
         {:ok, timer_reference} = set_refresh(expiration) do
      Enum.each(keys, fn key -> :ets.insert(@table, key) end)

      Logger.info("Added Google keys")

      {:ok, %{next_refresh: timer_reference}}
    end
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def fetch_certs do
    GenServer.call(__MODULE__, :fetch_certs)
  end

  def get_key(id) do
    GenServer.call(__MODULE__, {:get_key, id})
  end

  def refresh_keys do
    GenServer.call(__MODULE__, :refresh_keys)
  end

  def handle_call(:all, _from, state) do
    certs = :ets.tab2list(@table)
    {:reply, certs, state}
  end

  def handle_call(:fetch_certs, _from, state) do
    with %{expiration: _, keys: _} = certs <- get_certs() do
      {:reply, certs, state}
    end
  end

  def handle_call({:get_key, id}, _from, state) do
    with [key] <- :ets.lookup(@table, id) do
      {:reply, key, state}
    else
      [] -> {:reply, nil, state}
    end
  end

  def handle_call(:refresh_keys, _from, %{next_refresh: timer_reference}) do
    with {:ok, next_timer_reference} <- refresh(timer_reference) do
      certs = :ets.tab2list(@table)
      {:reply, certs, %{next_refresh: next_timer_reference}}
    end
  end

  def handle_info(:refresh_keys, %{next_refresh: timer_reference}) do
    with {:ok, next_timer_reference} <- refresh(timer_reference) do
      {:noreply, %{next_refresh: next_timer_reference}}
    end
  end

  defp build_key(%{
         "e" => e,
         "n" => n,
         "kid" => id,
         "alg" => "RS256",
         "kty" => "RSA",
         "use" => "sig"
       }) do
    {
      id,
      Base.url_decode64!(e, padding: false),
      Base.url_decode64!(n, padding: false)
    }
  end

  defp filter_max_age([]), do: nil

  defp filter_max_age([<<109, 97, 120, 45, 97, 103, 101, 61, age::binary>> | _tail]),
    do: String.to_integer(age)

  defp filter_max_age([_value | tail]), do: filter_max_age(tail)

  defp get_certs do
    with %HTTPoison.Response{
           status_code: 200,
           headers: headers,
           body: body
         } <- @http.get!(@certs_url, [], hackney: [:insecure]) do
      %{expiration: get_expiration(headers), keys: get_keys(body)}
    end
  end

  defp get_expiration(headers) do
    Enum.find(headers, fn {key, _} -> key == "Cache-Control" end)
    |> get_values()
  end

  defp get_keys(body) do
    with %{"keys" => keys} <- Jason.decode!(body) do
      Enum.map(keys, fn key -> build_key(key) end)
    end
  end

  defp get_values({"Cache-Control", values}) do
    String.split(values, ", ")
    |> filter_max_age()
  end

  defp refresh(timer_reference) do
    :timer.cancel(timer_reference)

    with %{expiration: expiration, keys: keys} <- get_certs(),
         {:ok, next_timer_reference} = set_refresh(expiration),
         true <- :ets.delete_all_objects(@table) do
      Enum.each(keys, fn key -> :ets.insert(@table, key) end)

      Logger.info("Refreshed Google keys")
      {:ok, next_timer_reference}
    end
  end

  defp set_refresh(seconds) do
    :timer.send_after(seconds * 1000, :refresh_keys)
  end
end
