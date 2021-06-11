defmodule HubIdentity.Administration.AdministratorNotifier do
  @moduledoc """
  Module to send notifications to the Administrators.
  """
  alias SendGrid.Email

  @email Application.get_env(:hub_identity, :email)

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(administrator, url) do
    deliver(
      administrator.email,
      """

      ==============================

      Hi #{administrator.email},

      You can confirm your account by visiting the URL below:

      #{url}

      If you didn't create an account with us, please ignore this.

      ==============================
      """,
      "Email confirmation instructions"
    )
  end

  @doc """
  Deliver instructions to reset a administrator password.
  """
  def deliver_reset_password_instructions(administrator, url) do
    deliver(
      administrator.email,
      """

      ==============================

      Hi #{administrator.email},

      You can reset your password by visiting the URL below:

      #{url}

      If you didn't request this change, please ignore this.

      ==============================
      """,
      "Reset password instructions"
    )
  end

  @doc """
  Deliver instructions to update a administrator email.
  """
  def deliver_update_email_instructions(administrator, url) do
    deliver(
      administrator.email,
      """

      ==============================

      Hi #{administrator.email},

      You can change your email by visiting the URL below:

      #{url}

      If you didn't request this change, please ignore this.

      ==============================
      """,
      "Email update instructions"
    )
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
