defmodule VisualsAdminWeb.MappingLive.Index do
  use VisualsAdminWeb, :live_view

  alias VisualsAdmin.Hyperion
  alias VisualsAdmin.Hyperion.Mapping

  @impl true
  def mount(_params, _session, socket) do

    #http://192.168.1.28:8090/json-rpc
    url = "http://127.0.0.1:8090/json-rpc"

    payload = %{
      "command" => "serverinfo",
      "subscribe" => ["all"],
      "tan" => 1
    }

    #HyperionControl.fetch_and_print_pretty_json(url)

    #load initial Hyperion serverinfo
    response = case Hyperion.post_json(url, payload) do
      {:ok, response} ->
        #IO.inspect(response, label: "Response")
        #dbg(response["info"])
        #{:ok, stream(socket, :hyperionserverinfo, response["instance"])}
        response
      {:error, reason} ->
        IO.inspect(reason, label: "Error")
        {:ok, assign(socket, :serverinfo, [])}
    end

    #{:ok, stream(socket, :mappings, Hyperion.list_mappings())}
    #{:ok, socket}
    {:ok, socket
      |> assign(:serverinfo, response["info"])
      |> assign(:leds, [])
      |> assign(:leds_pixel, [])
      |> assign(:size, %{ width: 0, height: 0})
      |> assign(:position, %{ top: 0, left: 0})
      |> assign(:selected, nil)
      |> assign(:led_width, nil)
      |> assign(:led_height, nil)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_event("size_change", %{"_target" => target, "led_height" => led_height, "led_width" => led_width}, socket) do
    #dbg(socket.assigns.leds)
    #dbg(socket.assigns.leds_pixel)

    leds_pixel_calc = Enum.map(socket.assigns.leds_pixel, fn led ->
      vmax = led.vmin + VisualsAdmin.Hyperion.parse_to_number(led_height)
      hmax = led.hmin + VisualsAdmin.Hyperion.parse_to_number(led_width)
      #dbg(led)
      %{
        #width => led_width,
        #height => led_height,
        hmax: hmax,
        hmin: led.hmin,
        vmax: vmax,
        vmin: led.vmin
      }
    end)

    leds = Enum.map(leds_pixel_calc, fn led ->
      {:ok, led_coordinates} = VisualsAdmin.Hyperion.get_led_coordinates(led, socket.assigns.size, socket.assigns.position)

        dbg(led_coordinates)

      %{
        "hmax" => led_coordinates.hmax,
        "hmin" => led_coordinates.hmin,
        "vmax" => led_coordinates.vmax,
        "vmin" => led_coordinates.vmin
      }

    end)

    #dbg(leds)

    {:noreply, socket
      |> assign(led_width: led_width)
      |> assign(led_height: led_height)
      |> assign(leds_pixel: leds_pixel_calc)
      |> assign(leds: leds)
    }
  end

  def handle_event("safe", %{"value" => ""}, socket) do
    dbg(socket.assigns.leds)
    #dbg(socket.assigns.leds_pixel)
    {:noreply, socket}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Mapping")
    #|> assign(:mapping, Hyperion.get_mapping!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Mapping")
    #|> assign(:mapping, %Mapping{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Mappings")
    |> assign(:mapping, nil)
  end

  #@impl true
  #def handle_info({VisualsAdminWeb.MappingLive.FormComponent, {:saved, mapping}}, socket) do
  #  {:noreply, stream_insert(socket, :mappings, mapping)}
  #end

  #@impl true
  #def handle_event("delete", %{"id" => id}, socket) do
  #  mapping = Hyperion.get_mapping!(id)
  #  {:ok, _} = Hyperion.delete_mapping(mapping)

  #  {:noreply, stream_delete(socket, :mappings, mapping)}
  #end

  def handle_event("select", value, socket) do
    dbg(value["select"])
    #{:noreply, assign(socket, :temperature, new_temp)}

    url = "http://127.0.0.1:8090/json-rpc"

    payload = %{
      "command" => "instance",
      "subcommand" => "switchTo",
      "instance" => String.to_integer(value["select"])
    }

    dbg(payload)


    case Hyperion.post_json(url, payload) do
      {:ok, response} ->
        #IO.inspect(response, label: "Response")
        #dbg(response["info"])
        #{:ok, stream(socket, :hyperionserverinfo, response["instance"])}
        {:ok, assign(socket, :serverinfo, response["info"])}
      {:error, reason} ->
        IO.inspect(reason, label: "Error")
        {:ok, assign(socket, :serverinfo, [])}
    end

    payload = %{
      "command" => "serverinfo"
    }

    leds = case Hyperion.post_json(url, payload) do
      {:ok, response} ->
        #IO.inspect(response, label: "Response")
        #dbg(response["info"]["leds"])
        #{:ok, stream(socket, :hyperionserverinfo, response["instance"])}

        #{:ok, socket
        #  |> assign(:serverinfo, response["info"])
        #  |> assign(:leds, response["info"]["leds"])
        #}
        #dbg(response["info"]["instance"])
        response["info"]["leds"]

      {:error, reason} ->
        IO.inspect(reason, label: "Error")
        #{:ok, assign(socket, :serverinfo, [])}
        []
    end


    leds_pixel = []

    #dbg(leds)

    #leds_pixel = for led <- leds, do:
    #  {:ok, led_pixel} = VisualsAdmin.Hyperion.get_led_pixel(led, socket.assigns.size, socket.assigns.position)
    #  dbg(led_pixel)
    #end

    leds_pixel = Enum.map(leds, fn led ->
      {:ok, led_pixel} = VisualsAdmin.Hyperion.get_led_pixel(led, socket.assigns.size, socket.assigns.position)
      led_pixel
    end)

    #dbg(leds_pixel)

    led_width = leds_pixel |> hd() |> Map.get(:width)
    led_height = leds_pixel |> hd() |> Map.get(:height)

    {:noreply,
      socket
      |> assign(:leds, leds)
      |> assign(:leds_pixel, leds_pixel)
      |> assign(:selected, String.to_integer(value["select"]))
      |> assign(:led_width, led_width)
      |> assign(:led_height, led_height)
      |> push_event("select-stripe", %{})
    }
  end

  def handle_event("div_size", %{"width" => width, "height" => height}, socket) do
    # Handle the size information as needed
    #IO.puts("Div width: #{width}, height: #{height}")
    size = %{
      width: width,
      height: height
    }
    IO.puts("size: #{inspect(size)}")
    {:noreply, assign(socket, size: size)}
  end

  def handle_event("mapping_position", %{"top" => top, "left" => left}, socket) do
    # Handle the size information as needed
    #IO.puts("Div width: #{width}, height: #{height}")
    position = %{
      top: top,
      left: left
    }
    IO.puts("size: #{inspect(position)}")
    {:noreply, assign(socket, position: position)}
  end

end
