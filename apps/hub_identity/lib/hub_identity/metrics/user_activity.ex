defmodule HubIdentity.Metrics.UserActivity do
  @moduledoc """
  Module to store the user activities for BI purposes.
  """
  use Ecto.Schema
  use HubIdentity.Uid

  import Ecto.Changeset

  # authenticate or login
  @types [
    "AccessCookie.create",
    "AccessToken.create",
    "AccessCookie.redirect",
    "Email.create",
    "Email.delete",
    "Identity.create",
    "Identity.delete",
    "User.create",
    "User.delete",
    "Verification.success"
  ]

  schema "user_activities" do
    field :client_service_uid, :string
    field :owner_type, :string
    field :owner_uid, :string
    field :provider, :string
    field :remote_address, :string
    field :type, :string
    field :user_agent, :string
    field :uid, :string

    field :owner, :map, virtual: true
    timestamps()
  end

  @doc false
  def changeset(user_activity, attrs, conn \\ nil) do
    user_activity
    |> cast(attrs, [
      :client_service_uid,
      :owner,
      :owner_uid,
      :owner_type,
      :provider,
      :type
    ])
    |> validate_required([:owner_uid, :owner_type, :provider, :type])
    |> validate_inclusion(:type, @types)
    |> parse_conn(conn)
    |> put_uid()
  end

  def create_changeset(user_activity, attrs, conn \\ nil) do
    user_activity
    |> cast(attrs, [
      :client_service_uid,
      :owner,
      :provider
    ])
    |> parse_owner("create")
    |> parse_conn(conn)
    |> put_uid()
  end

  def delete_changeset(user_activity, attrs, conn \\ nil) do
    user_activity
    |> cast(attrs, [
      :client_service_uid,
      :owner,
      :provider
    ])
    |> parse_owner("delete")
    |> parse_conn(conn)
    |> put_uid()
  end

  defp get_remote_address(%Plug.Conn{
         remote_ip: {first_octet, second_octet, third_octet, fourth_octet}
       }),
       do: "#{first_octet}.#{second_octet}.#{third_octet}.#{fourth_octet}"

  defp get_remote_address(_), do: "none"

  defp get_struct_name(HubIdentity.Identities.Email), do: "Email"

  defp get_struct_name(HubIdentity.Identities.User), do: "User"

  defp get_struct_name(HubIdentity.Identities.Identity), do: "Identity"

  defp get_user_agent(conn) do
    Plug.Conn.get_req_header(conn, "user-agent") |> List.to_string()
  end

  defp parse_conn(changeset, %Plug.Conn{} = conn) do
    changeset
    |> put_change(:remote_address, get_remote_address(conn))
    |> put_change(:user_agent, get_user_agent(conn))
  end

  defp parse_conn(changeset, _), do: changeset

  defp parse_owner(
         %Ecto.Changeset{changes: %{owner: %{uid: uid, __struct__: struct_name}}} = changeset,
         type
       ) do
    name = get_struct_name(struct_name)

    changeset
    |> put_change(:owner_uid, uid)
    |> put_change(:owner_type, name)
    |> put_change(:type, "#{name}.#{type}")
  end

  defp parse_owner(changeset, _type), do: changeset
end
