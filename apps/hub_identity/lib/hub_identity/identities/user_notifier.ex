defmodule HubIdentity.Identities.UserNotifier do
  @moduledoc """
    UserNotifier is used to send emails to the user to Confirm himself when its require.
  """
  alias SendGrid.Email
  require Logger

  @email Application.get_env(:hub_identity, :email)

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(address, url) do
    deliver(
      address,
      """

      ==============================

      Hi #{address},

      You can confirm your account by visiting the URL below:

      #{url}

      If you didn't create an account with us, please ignore this.

      ==============================
      """,
      "Email confirmation instructions"
    )
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(address, url) do
    deliver(
      address,
      """

      ==============================

      Hi #{address},

      You can reset your password by visiting the URL below:

      #{url}

      If you didn't request this change, please ignore this.

      ==============================
      """,
      "Reset password instructions"
    )
  end

  @doc """
  Deliver email to inform user primary email has changed.
  """

  def deliver_primary_email_change_notification(email) do
    deliver(
      email.address,
      """

      ==============================

      Hi #{email.address},

      Your HubIdentity account primary email has changed.

      This email is no longer your primary email.

      If you didn't request this change, please login to your application and update your settings.

      ==============================
      """,
      "Primary Email change notification"
    )
  end

  @doc """
  Deliver email for 2 factor verification.
  """
  def deliver_verification_code(email, client_service, code) do
    deliver(
      email.address,
      """

      ==============================

      Hi #{email.address},

      #{client_service.name} is requesting a 2 factor verification.

      Please provide the following code to #{client_service.name}

      code: #{code}

      ==============================
      """,
      "Two Factor Verification notification"
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
