defmodule VisualsAdminWeb.MappingLive.Show do
  use VisualsAdminWeb, :live_view

  alias VisualsAdmin.Hyperion

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:mapping, Hyperion.get_mapping!(id))}
  end

  defp page_title(:show), do: "Show Mapping"
  defp page_title(:edit), do: "Edit Mapping"
end
