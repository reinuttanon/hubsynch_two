defmodule HubIdentity.Providers.GoogleCertsServerTest do
  use HubIdentity.DataCase

  alias HubIdentity.Providers.GoogleCertsServer

  describe "all/0" do
    test "returns all the certs stored in memory" do
      keys = GoogleCertsServer.all()

      for key <- keys do
        {id, e, n} = key
        assert id != nil
        assert e != nil
        assert n != nil
      end
    end
  end

  describe "fetch_certs/0" do
    test "returns certs from Google and expiration" do
      %{expiration: expiration, keys: keys} = GoogleCertsServer.fetch_certs()
      assert expiration == 18265
      assert length(keys) == 2

      for key <- keys do
        {id, e, n} = key
        assert id != nil
        assert e != nil
        assert n != nil
      end
    end
  end

  describe "get_key/1" do
    test "returns the key with the id" do
      {id, e, n} = GoogleCertsServer.get_key("eea1b1f42807a8cc136a03a3c16d29db8296daf0")
      assert id == "eea1b1f42807a8cc136a03a3c16d29db8296daf0"
      assert e == <<1, 0, 1>>
      assert n != nil
    end

    test "returns nil if no key" do
      assert nil == GoogleCertsServer.get_key("nosfkjaiofjsadoijfsaksfjl")
    end
  end

  describe "refresh_keys/0" do
    test "returns they keys in the server" do
      keys = GoogleCertsServer.refresh_keys()

      for key <- keys do
        {id, e, n} = key
        assert id != nil
        assert e != nil
        assert n != nil
      end
    end
  end
end
