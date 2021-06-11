defmodule HubLedgerWeb.PageControllerTest do
  use HubLedgerWeb.ConnCase
  setup :register_and_log_in_administrator

  test "GET /" do
    conn = get(build_conn(), "/")
    assert html_response(conn, 200) =~ "HubLedger"
  end
end
