defmodule HubPaymentsWeb.Api.V1.WalletView do
  use HubPaymentsWeb, :view

  def render("show.json", %{wallet: wallet}) do
    %{
      "Object" => "Wallet",
      "owner" => %{
        "Object" => wallet.owner.object,
        "uid" => wallet.owner.uid
      },
      "prefered_credit_card_uuid" => wallet.prefered_credit_card_uuid,
      "uuid" => wallet.uuid
    }
  end
end
