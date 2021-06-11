defmodule HubIdentity.Encryption.Helpers do
  def generate_data do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end

  def generate_data(prefix) do
    "#{prefix}_#{generate_data()}"
  end
end
