defmodule HubIdentity.ClientServices.StateServerTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.ClientServices.{StateSecret, StateServer}
  alias HubCluster.MementoRepo

  @clear_interval 600_000

  describe "delete_expired/1" do
    test "removes all secrets with an date older than the given date" do
      now = DateTime.utc_now()
      now_timestamp = DateTime.to_unix(now)
      eleven_min = DateTime.add(now, -660_000) |> DateTime.to_unix()
      nine_min = DateTime.add(now, -540_000) |> DateTime.to_unix()
      ten_min = DateTime.add(now, -@clear_interval) |> DateTime.to_unix()

      owner = insert(:client_service)

      for _ <- 1..3 do
        %StateSecret{secret: create_secret(), owner: owner, created_at: now_timestamp}
        |> MementoRepo.insert()

        %StateSecret{secret: create_secret(), owner: owner, created_at: eleven_min}
        |> MementoRepo.insert()

        %StateSecret{secret: create_secret(), owner: owner, created_at: nine_min}
        |> MementoRepo.insert()
      end

      pre_purge = MementoRepo.all(StateSecret)
      assert length(pre_purge) >= 9
      StateServer.delete_expired(ten_min)
      post_purge = MementoRepo.all(StateSecret)
      assert length(post_purge) == length(pre_purge) - 3

      for state_secret <- post_purge do
        assert state_secret.created_at > ten_min
      end
    end
  end

  defp create_secret do
    :crypto.strong_rand_bytes(6)
    |> Base.encode64()
  end
end
