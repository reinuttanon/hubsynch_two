defmodule HubPaymentsWeb.Api.V1.WalletView do
  use HubPaymentsWeb, :view
  alias HubPayments.Wallets.Wallet

  def render("show.json", %{wallet: %Wallet{credit_cards: credit_cards} = wallet})
      when is_list(credit_cards) do
    %{
      "Object" => "Wallet",
      "owner" => %{
        "Object" => wallet.owner.object,
        "uid" => wallet.owner.uid
      },
      "prefered_credit_card_uuid" => wallet.prefered_credit_card_uuid,
      "uuid" => wallet.uuid,
      "credit_cards" =>
        render_many(credit_cards, HubPaymentsWeb.Api.V1.CreditCardView, "show.json")
    }
  end

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
