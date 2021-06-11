defmodule HubIdentityWeb.PageController do
  @moduledoc false

  use HubIdentityWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def privacy_policy(conn, %{"lang" => lang}) do
    render(conn, "privacy_policy_#{lang}.html")
  end

  def privacy_policy(conn, _params) do
    render(conn, "privacy_policy_jp.html")
  end

  def terms_of_service(conn, _params) do
    render(conn, "terms_of_service.html")
  end
end
