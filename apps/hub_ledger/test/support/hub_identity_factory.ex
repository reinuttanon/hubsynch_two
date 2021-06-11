defmodule HubLedger.HubIdentityFactory do
  # with Ecto
  use ExMachina.Ecto, repo: HubLedger.HubIdentityRepo

  alias HubLedger.ApiKeys.ApiKey

  def api_key_factory do
    {1, [%{id: client_service_id}]} = create_client_service()

    %ApiKey{
      client_service_id: client_service_id,
      data: generate_data("priv_"),
      type: "private",
      uid: Ecto.UUID.generate()
    }
  end

  defp generate_data(prefix \\ "") do
    data =
      :crypto.strong_rand_bytes(32)
      |> Base.encode64()

    "#{prefix}#{data}"
  end

  defp create_client_service do
    HubLedger.HubIdentityRepo.insert_all(
      "client_services",
      [
        %{
          name: "test",
          uid: generate_data(),
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      ],
      returning: [:id]
    )
  end
end
