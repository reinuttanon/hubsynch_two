defmodule HubIdentity.Verifications.EmailVerifyReference do
  import HubIdentity.Encryption.Helpers, only: [generate_data: 0]

  @max_age 86_400

  use Memento.Table,
    attributes: [
      :id,
      :address,
      :client_service_uid,
      :expires_at,
      :provider_info,
      :redirect_url,
      :reference,
      :user
    ],
    index: [:reference, :address],
    type: :ordered_set,
    autoincrement: true

  @doc """
  A email verification reference changeset.
  This will add an expiration date and a random generated reference to track
  the user that makes the verificacion request.
  """
  def create_changeset(attrs) do
    Map.merge(%__MODULE__{}, attrs)
    |> Map.put(:expires_at, expires_at())
    |> Map.put(:reference, generate_data())
  end

  @doc """
  Defines how long the reference will be available. (seconds)
  """
  def max_age, do: @max_age

  defp expires_at do
    DateTime.utc_now()
    |> DateTime.add(@max_age, :second)
    |> DateTime.to_unix()
  end
end
