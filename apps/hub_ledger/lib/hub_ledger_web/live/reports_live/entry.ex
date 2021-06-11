defmodule HubLedgerWeb.ReportsLive.Entry do
  use HubLedgerWeb, :live_view

  alias HubLedger.Ledgers
  alias HubLedger.Ledgers.Entry
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
  def handle_event("validate", %{"parameters" => %{"uuid" => ""}}, socket) do
    {:noreply, assign(socket, :errors, %{})}
  end

  @impl true
  def handle_event("validate", %{"parameters" => %{"uuid" => uuid}}, socket) do
    case Ledgers.get_entry(%{uuid: uuid}) do
      nil -> {:noreply, assign(socket, :errors, %{"uuid" => "invalid entry UUID"})}
      %Entry{} -> {:noreply, assign(socket, :errors, %{})}
    end
  end

  @impl true
  def handle_event("view_sample", _parameters, socket) do
    case socket.assigns.parameters["preload"] do
      "true" -> transaction_sample(socket)
      _ -> entries_sample(socket)
    end
  end

  @impl true
  def handle_event("reset", _, socket) do
    new_socket =
      socket
      |> assign(:total_records, 0)
      |> assign(:parameters, default_parameters())
      |> assign(:entries, [])
      |> assign(:errors, %{})

    {:noreply, new_socket}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :page_title, "Journal Entry Report Generator")
  end

  defp entries_sample(socket) do
    entries = Reports.entries_sample(socket.assigns.parameters)

    new_socket =
      socket
      |> assign(:page_title, "Sample Report")
      |> assign(:component, HubLedgerWeb.ReportsLive.EntriesSample)
      |> assign(:entries, entries)
      |> assign(:transactions, [])
      |> assign(:live_action, :view_sample)

    {:noreply, new_socket}
  end

  defp transaction_sample(socket) do
    transactions = Reports.entries_sample(socket.assigns.parameters)

    new_socket =
      socket
      |> assign(:page_title, "Sample Report")
      |> assign(:component, HubLedgerWeb.ReportsLive.TransactionsSample)
      |> assign(:entries, [])
      |> assign(:transactions, transactions)
      |> assign(:live_action, :view_sample)

    {:noreply, new_socket}
  end

  defp update_parameters(%{"uuids" => uuids} = parameters, %{"uuid" => uuid}) do
    case Ledgers.get_entry(%{uuid: uuid}) do
      nil ->
        {:error, %{"uuid" => "invalid entry UUID"}}

      %Entry{} ->
        parameters
        |> Map.delete("uuid")
        |> Map.put("uuids", Enum.uniq([uuid | uuids]))
    end
  end

  defp update_parameters(parameters, %{"order_by" => "asc", "preload" => preload}) do
    parameters
    |> Map.put("order_by", "asc")
    |> Map.put("preload", preload)
    |> Map.put("order_options", Ascending: "asc", Descending: "desc")
  end

  defp update_parameters(parameters, %{"order_by" => "desc", "preload" => preload}) do
    parameters
    |> Map.put("order_by", "desc")
    |> Map.put("preload", preload)
    |> Map.put("order_options", Descending: "desc", Ascending: "asc")
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

  defp update_parameters(parameters, new_parameters) do
    Map.merge(parameters, new_parameters)
  end

  defp default_parameters do
    %{
      "uuids" => [],
      "order_by" => "desc",
      "order_options" => [Descending: "desc", Ascending: "asc"],
      "preload" => false
    }
  end

  defp update_count(socket) do
    case Reports.entries_count(socket.assigns.parameters) do
      total when is_integer(total) -> assign(socket, :total_records, total)
      _ -> socket
    end
  end
end
