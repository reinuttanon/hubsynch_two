defmodule HubLedger.Reports do
  alias HubLedger.Reports.{Accounts, Entries, Transactions}

  def accounts_count(report_params) do
    Accounts.generate_count(report_params)
  end

  def accounts_report(report_params) do
    Accounts.generate(report_params)
  end

  def accounts_sample(report_params) do
    Accounts.generate_sample(report_params)
  end

  def entries_report(report_params) do
    Entries.generate(report_params)
  end

  def entries_count(report_params) do
    Entries.generate_count(report_params)
  end

  def entries_sample(report_params) do
    Entries.generate_sample(report_params)
  end

  def transactions_report(report_params) do
    Transactions.generate(report_params)
  end

  def transactions_count(report_params) do
    Transactions.generate_count(report_params)
  end

  def transactions_sample(report_params) do
    Transactions.generate_sample(report_params)
  end
end
