defmodule HubLedgerWeb.DownloadController do
  @moduledoc false

  use HubLedgerWeb, :controller

  alias HubLedger.Reports
  alias HubLedger.Reports.CsvExporter

  def csv_download(conn, report_params) do
    csv_content =
      report_params
      |> report()
      |> CsvExporter.generate()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"#{report_name(report_params)}\""
    )
    |> send_resp(200, csv_content)
  end

  defp report(%{"accounts" => report_params}), do: Reports.accounts_report(report_params)

  defp report(%{"entries" => report_params}), do: Reports.entries_report(report_params)

  defp report(%{"transactions" => report_params}), do: Reports.transactions_report(report_params)

  defp report_name(%{"accounts" => _report_params}), do: "AccountsReport.csv"

  defp report_name(%{"entries" => _report_params}), do: "EntriesReport.csv"

  defp report_name(%{"transactions" => _report_params}), do: "TransactionsReport.csv"
end
