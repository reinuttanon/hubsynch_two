defmodule HubLedgerWeb.ReportsLive.Transaction do
  use HubLedgerWeb, :live_view

  alias HubLedger.{Accounts, Reports}
  alias HubLedger.Accounts.Account

  @impl true
  def mount(_params, _session, socket) do
    new_socket =
      socket
      |> assign(:total_records, 0)
      |> assign(:parameters, default_parameters())
      |> assign(:errors, %{})

    {:ok, new_socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("add", %{"parameters" => parameters}, socket) do
    new_params = update_parameters(socket.assigns.parameters, parameters)

    new_socket =
      socket
      |> assign(:parameters, new_params)
      |> assign(:errors, %{})
      |> update_count()

    {:noreply, new_socket}
  end

  @impl true
  def handle_event(
        "options",
        %{"options" => parameters},
        socket
      ) do
    new_params = update_parameters(socket.assigns.parameters, parameters)

    new_socket =
      socket
      |> assign(:parameters, new_params)
      |> assign(:errors, %{})

    {:noreply, new_socket}
  end

  @impl true
  def handle_event("view_sample", _parameters, socket) do
    transactions = Reports.transactions_sample(socket.assigns.parameters)

    new_socket =
      socket
      |> assign(:page_title, "Sample Report")
      |> assign(:component, HubLedgerWeb.ReportsLive.TransactionsSample)
      |> assign(:transactions, transactions)
      |> assign(:live_action, :view_sample)

    {:noreply, new_socket}
  end

  @impl true
  def handle_event("reset", _, socket) do
    new_socket =
      socket
      |> assign(:total_records, 0)
      |> assign(:parameters, default_parameters())
      |> assign(:transactions, [])
      |> assign(:errors, %{})

    {:noreply, new_socket}
  end

  @impl true
  def handle_event("validate", %{"parameters" => %{"account_uuid" => ""}}, socket) do
    {:noreply, assign(socket, :errors, %{})}
  end

  @impl true
  def handle_event("validate", %{"parameters" => %{"account_uuid" => uuid}}, socket) do
    case Accounts.get_account(%{uuid: uuid}) do
      nil -> {:noreply, assign(socket, :errors, %{"account_uuid" => "invalid entry UUID"})}
      %Account{} -> {:noreply, assign(socket, :errors, %{})}
    end
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :page_title, "Transaction Report")
  end

  defp update_parameters(parameters, %{"order_by" => "asc"}) do
    parameters
    |> Map.put("order_by", "asc")
    |> Map.put("order_options", Ascending: "asc", Descending: "desc")
  end

  defp update_parameters(parameters, %{"order_by" => "desc"}) do
    parameters
    |> Map.put("order_by", "desc")
    |> Map.put("order_options", Descending: "desc", Ascending: "asc")
  end

  defp update_parameters(parameters, %{"kind" => kind} = new_parameters) do
    kinds = reorder_kinds(kind)

    parameters
    |> Map.merge(new_parameters)
    |> Map.put("kinds", kinds)
  end

  defp update_parameters(parameters, new_parameters) do
    Map.merge(parameters, new_parameters)
  end

  defp reorder_kinds("credit"), do: ["credit", "debit", "all"]

  defp reorder_kinds("debit"), do: ["debit", "credit", "all"]

  defp reorder_kinds(_), do: ["all", "credit", "debit"]

  defp default_parameters do
    %{
      "kind" => "all",
      "kinds" => ["all", "credit", "debit"],
      "order_by" => "desc",
      "order_options" => [Descending: "desc", Ascending: "asc"]
    }
  end

  defp update_count(socket) do
    case Reports.transactions_count(socket.assigns.parameters) do
      total when is_integer(total) -> assign(socket, :total_records, total)
      _ -> socket
    end
  end
end
