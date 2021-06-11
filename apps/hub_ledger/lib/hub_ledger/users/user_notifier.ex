defmodule HubLedger.Users.UserNotifier do
  alias SendGrid.Email
  require Logger

  alias HubLedger.Users

  @email Application.get_env(:hub_ledger, :email)
  @hub_identity_user Application.get_env(:hub_ledger, :hub_identity_user)
  @doc """
  Deliver instructions to confirm account.
  """

  def deliver_confirmation_to_all_admins(address, url) do
    Users.list_users(%{role: "admin"})
    |> Stream.map(&get_user_email(&1.hub_identity_uid))
    |> Stream.each(&deliver_access_request(&1, address, url))
    |> Stream.run()
  end

  def deliver_access_request(admin_address, address, url) do
    deliver(
      admin_address,
      """

      ==============================

      Hi #{admin_address},

      #{address} wants to get access to Hub Ledger.

      #{url}

      If you didn't create an account with us, please ignore this.

      ==============================
      """,
      "Email confirmation instructions"
    )
  end

  def deliver_confirmation_instructions([], _address, _url), do: {:ok, "Message sent"}

  def deliver_access_notification(address, url) do
    deliver(
      address,
      """

      ==============================

      Hi #{address},

      Your Hub-Ledger Account has been confirmed.

      You can access to Hub-Ledger clicking the link below.

      #{url}

      If you didn't create an account with us, please ignore this.

      ==============================
      """,
      "Email confirmation instructions"
    )
  end

  @doc """
  For development environment to test sending messages.
  This will ouput to terminal
  """
  def send(%SendGrid.Email{content: content}) do
    for %{value: message} <- content do
      Logger.info(message)
    end

    :ok
  end

  defp get_user_email(hub_identity_uid) do
    {:ok, %{"emails" => [%{"address" => admin_address, "primary" => true}]}} =
      @hub_identity_user.get(%{uid: hub_identity_uid})

    admin_address
  end

  defp deliver(to, body, subject) do
    email =
      Email.build()
      |> Email.add_to(to)
      |> Email.put_from("info@hubidentity.com")
      |> Email.put_subject(subject)
      |> Email.put_text(body)

    case @email.send(email) do
      :ok -> {:ok, %{to: to, body: body}}
      {:error, message} -> {:error, message}
    end
  end
end
