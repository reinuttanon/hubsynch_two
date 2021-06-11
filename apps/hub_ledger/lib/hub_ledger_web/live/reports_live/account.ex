defmodule HubLedgerWeb.ReportsLive.Account do
  use HubLedgerWeb, :live_view

  alias HubLedger.Accounts
  alias HubLedger.Accounts.Account
  alias HubLedger.Reports

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
    case socket.assigns.parameters["report_type"] do
      "balances" -> balances_report(socket)
      _ -> accounts_report(socket)
    end
  end

  @impl true
  def handle_event("reset", _, socket) do
    new_socket =
      socket
      |> assign(:total_records, 0)
      |> assign(:parameters, default_parameters())
      |> assign(:errors, %{})

    {:noreply, new_socket}
  end

  @impl true
  def handle_event("validate", %{"parameters" => %{"uuid" => ""}}, socket) do
    {:noreply, assign(socket, :errors, %{})}
  end

  @impl true
  def handle_event("validate", %{"parameters" => %{"uuid" => uuid}}, socket) do
    case Accounts.get_account(%{uuid: uuid}) do
      nil -> {:noreply, assign(socket, :errors, %{"uuid" => "invalid entry UUID"})}
      %Account{} -> {:noreply, assign(socket, :errors, %{})}
    end
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :page_title, "Account Report Generator")
  end

  defp accounts_report(socket) do
    accounts = Reports.accounts_sample(socket.assigns.parameters)

    new_socket =
      socket
      |> assign(:page_title, "Sample Report")
      |> assign(:component, HubLedgerWeb.ReportsLive.AccountsSample)
      |> assign(:accounts, accounts)
      |> assign(:balances, [])
      |> assign(:live_action, :view_sample)

    {:noreply, new_socket}
  end

  defp balances_report(socket) do
    balances = Reports.accounts_sample(socket.assigns.parameters)

    new_socket =
      socket
      |> assign(:page_title, "Sample Report")
      |> assign(:component, HubLedgerWeb.ReportsLive.BalancesSample)
      |> assign(:accounts, [])
      |> assign(:balances, balances)
      |> assign(:live_action, :view_sample)

    {:noreply, new_socket}
  end

  defp update_parameters(%{"uuids" => uuids} = parameters, %{"uuid" => uuid}) do
    case Accounts.get_account(%{uuid: uuid}) do
      nil ->
        {:error, %{"uuid" => "invalid entry UUID"}}

      %Account{} ->
        parameters
        |> Map.delete("uuid")
        |> Map.put("uuids", Enum.uniq([uuid | uuids]))
    end
  end

  defp update_parameters(%{"owner" => owner} = parameters, %{"owner_object" => object}) do
    new_owner = Map.merge(owner, %{"object" => object})
    Map.put(parameters, "owner", new_owner)
  end

  defp update_parameters(%{"owner" => owner} = parameters, %{"owner_uid" => uid}) do
    new_owner = Map.merge(owner, %{"uid" => uid})
    Map.put(parameters, "owner", new_owner)
  end

  defp update_parameters(parameters, %{"owner_object" => object}) do
    Map.put(parameters, "owner", %{"object" => object})
  end

  defp update_parameters(parameters, %{"owner_uid" => uid}) do
    Map.put(parameters, "owner", %{"uid" => uid})
  end

  defp update_parameters(parameters, %{"report_type" => type}) do
    Map.put(parameters, "report_type", type)
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

  defp update_parameters(parameters, new_parameters) do
    Map.merge(parameters, new_parameters)
  end

  defp default_parameters do
    %{
      "uuids" => [],
      "report_type" => "created",
      "active" => true,
      "order_by" => "desc",
      "order_options" => [Descending: "desc", Ascending: "asc"]
    }
  end

  defp update_count(socket) do
    case socket.assigns.parameters["report_type"] do
      "created" -> update_accounts_count(socket)
      "balances" -> update_balances_count(socket)
    end
  end

  defp update_accounts_count(socket) do
    case Reports.accounts_count(socket.assigns.parameters) do
      total when is_integer(total) -> assign(socket, :total_records, total)
      _ -> socket
    end
  end

  defp update_balances_count(socket) do
    new_parameters = Map.delete(socket.assigns.parameters, "from_date") |> Map.delete("to_date")

    case Reports.accounts_count(new_parameters) do
      total when is_integer(total) -> assign(socket, :total_records, total)
      _ -> socket
    end
  end
end
