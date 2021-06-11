defmodule HubIdentity.Administration.AdministratorToken do
  @moduledoc """
  Module to handle Administrator Token.
  """
  use Ecto.Schema
  import Ecto.Query

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  schema "administrators_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :administrator, HubIdentity.Administration.Administrator

    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.
  """
  def build_session_token(administrator) do
    token = :crypto.strong_rand_bytes(@rand_size)

    {token,
     %HubIdentity.Administration.AdministratorToken{
       token: token,
       context: "session",
       administrator_id: administrator.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the administrator found by the token.
  """
  def verify_session_token_query(token) do
    query =
      from token in token_and_context_query(token, "session"),
        join: administrator in assoc(token, :administrator),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: administrator

    {:ok, query}
  end

  @doc """
  Builds a token with a hashed counter part.

  The non-hashed token is sent to the administrator email while the
  hashed part is stored in the database, to avoid reconstruction.
  The token is valid for a week as long as administrators don't change
  their email.
  """
  def build_email_token(administrator, context) do
    build_hashed_token(administrator, context, administrator.email)
  end

  defp build_hashed_token(administrator, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %HubIdentity.Administration.AdministratorToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       administrator_id: administrator.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the administrator found by the token.
  """
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in token_and_context_query(hashed_token, context),
            join: administrator in assoc(token, :administrator),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == administrator.email,
            select: administrator

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the administrator token record.
  """
  def verify_change_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Returns the given token with the given context.
  """
  def token_and_context_query(token, context) do
    from HubIdentity.Administration.AdministratorToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Gets all tokens for the given administrator for the given contexts.
  """
  def administrator_and_contexts_query(administrator, :all) do
    from t in HubIdentity.Administration.AdministratorToken,
      where: t.administrator_id == ^administrator.id
  end

  def administrator_and_contexts_query(administrator, [_ | _] = contexts) do
    from t in HubIdentity.Administration.AdministratorToken,
      where: t.administrator_id == ^administrator.id and t.context in ^contexts
  end
end
