defmodule HubPayments.Providers.Paygent.MessageBuilder do
  alias HubPayments.Payments.Charge
  alias HubPayments.Providers.Message
  alias HubPayments.Wallets.CreditCard

  @merchant_id "21220"
  @connect_id "hivelocity2test"
  @connect_password "2jjK9F2ast4NkBHS"

  def build_authorization(%Charge{money: money}, %CreditCard{
        uuid: uuid,
        exp_month: exp_month,
        exp_year: exp_year
      }) do
    %{
      "provider" => "paygent",
      "type" => "authorization",
      "values" => %{
        "merchant_id" => @merchant_id,
        "connect_id" => @connect_id,
        "connect_password" => @connect_password,
        "telegram_kind" => "020",
        "telegram_version" => "1.0",
        "payment_amount" => money.amount,
        "card_number" => uuid,
        "card_valid_term" => exp_month <> exp_year,
        "payment_class" => "10",
        "3dsecure_ryaku" => "1"
      }
    }
    |> Jason.encode()
  end

  def build_authorization(_, _), do: {:error, "Invalid charge values"}

  def build_authorization(
        %Charge{money: money},
        %CreditCard{
          exp_month: exp_month,
          exp_year: exp_year
        },
        token_uuid
      ) do
    %{
      "provider" => "paygent",
      "type" => "authorization",
      "values" => %{
        "merchant_id" => @merchant_id,
        "connect_id" => @connect_id,
        "connect_password" => @connect_password,
        "telegram_kind" => "020",
        "telegram_version" => "1.0",
        "payment_amount" => money.amount,
        "card_number" => token_uuid,
        "card_valid_term" => exp_month <> exp_year,
        "payment_class" => "10",
        "3dsecure_ryaku" => "1"
      }
    }
    |> Jason.encode()
  end

  def build_authorization(_, _, _), do: {:error, "Invalid charge values"}

  def build_capture(%Charge{money: money}, %Message{data: data}) do
    request_values = [
      {"merchant_id", @merchant_id},
      {"connect_id", @connect_id},
      {"connect_password", @connect_password},
      {"telegram_kind", "022"},
      {"telegram_version", "1.0"},
      {"payment_amount", money.amount},
      {"payment_id", data[:payment_id]}
    ]

    {:ok, url_encode(request_values)}
  end

  def build_capture(_, _), do: {:error, "Invalid charge values"}

  defp url_encode(values, encoded \\ "")

  defp url_encode([], encoded), do: encoded

  defp url_encode([{key, value} | values], "") do
    url_encode(values, "#{key}=#{value}")
  end

  defp url_encode([{key, value} | values], encoded) do
    url_encode(values, "#{encoded}&#{key}=#{value}")
  end
end
