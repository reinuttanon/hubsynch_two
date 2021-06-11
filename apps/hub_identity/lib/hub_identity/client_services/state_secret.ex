defmodule HubIdentity.ClientServices.StateSecret do
  @moduledoc false
  @secret_length 24

  use Memento.Table,
    attributes: [:secret, :owner, :created_at],
    index: [:created_at],
    type: :set

  @doc false
  def create_changeset(client_service) do
    %__MODULE__{
      secret: create_secret(),
      owner: client_service,
      created_at: DateTime.utc_now() |> DateTime.to_unix()
    }
  end

  defp create_secret do
    :crypto.strong_rand_bytes(@secret_length)
    |> Base.encode16()
  end
end
