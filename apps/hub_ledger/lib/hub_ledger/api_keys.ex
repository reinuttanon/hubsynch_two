defmodule HubLedger.ApiKeys do
  @moduledoc """
  The ClientServices context.
  """

  import Ecto.Query, warn: false

  alias HubLedger.ApiKeys.ApiKey
  alias HubLedger.HubIdentityRepo

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

    HubIdentityRepo.one_present!(query)
  end

  def get_api_key_by_data(data) do
    query =
      from a in ApiKey,
        where: a.data == ^data

    HubIdentityRepo.one_present(query)
  end
end
