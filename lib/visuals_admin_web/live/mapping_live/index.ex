defmodule VisualsAdminWeb.MappingLive.Index do
  use VisualsAdminWeb, :live_view

  alias VisualsAdmin.Hyperion
  alias VisualsAdmin.Hyperion.Mapping

  @impl true
  def mount(params, _session, socket) do

    #http://192.168.1.28:8090/json-rpc

    payload = %{
      "command" => "serverinfo",
      "subscribe" => ["all"],
      "tan" => 1
    }

    #HyperionControl.fetch_and_print_pretty_json(url)

    #load initial Hyperion serverinfo
    response = case Hyperion.post_json(payload) do
      {:ok, response} ->
        #IO.inspect(response, label: "Response")
        #dbg(response["info"])
        #{:ok, stream(socket, :hyperionserverinfo, response["instance"])}
        response
      {:error, reason} ->
        IO.inspect(reason, label: "Error")
        #{:ok, assign(socket, :serverinfo, [])}
        %{"info" => %{"error" => true, "reason" => "Hyperion not reachable", "instance" => []}}
    end

    hyperion_connected = case response do
      %{"info" => %{"error" => true, "instance" => []}} -> false
      _ -> true
    end


    #{:ok, stream(socket, :mappings, Hyperion.list_mappings())}
    #{:ok, socket}
    {:ok, socket
      |> assign(:hyperion_connected, hyperion_connected)
      |> assign(:serverinfo, response["info"])
      |> assign(:current_config, %{})
      |> assign(:leds, [])
      |> assign(:leds_pixel, [])
      |> assign(:size, %{ width: 0, height: 0})
      |> assign(:position, %{ top: 0, left: 0})
      |> assign(:selected, nil)
      |> assign(:led_width, nil)
      |> assign(:led_height, nil)
      |> assign(:point_messure, 0.0)
      |> assign(:verticies, %{})
      |> assign(:debug, Map.has_key?(params, "debug"))

    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_event("size_change", %{"_target" => target, "led_height" => led_height, "led_width" => led_width}, socket) do
    #dbg(socket.assigns.leds)
    #dbg(socket.assigns.leds_pixel)
    dbg(led_height)
    dbg(led_width)

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

        #dbg(led_coordinates)

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

  def handle_event("save", %{"instance" => instance, "value" => _value}, socket) do
    #dbg(socket.assigns.leds)
    #dbg(socket.assigns.leds_pixel)


    #payload = %{
    #  "command" => "serverinfo",
    #  "subscribe" => ["all"],
    #  "tan" => 1
    #}

    #changes = %{ "leds" => socket.assigns.leds }

      #payload = %{
      #  "command" => "config",
      #  "setconfig" => changes,
      #  "instance" => String.to_integer(instance)
      #}

      payload = %{
        "command" => "config",
        "subcommand" => "getconfig",
        "tan" => 1
      }

      #payload = %{
      #  command: "authorize",
      #  subcommand: "login",
      #  tan: 1,
      #}

      #payload = %{
      #  "command" => "settings-update",
      #  "data" => changes,
      #  "instance" => 15
      #}

    dbg(payload)

    #{"command":"settings-update","data":{"leds":[]},"instance":15}

    #HyperionControl.fetch_and_print_pretty_json(url)

    #load initial Hyperion config
    config_response = case Hyperion.post_json(payload) do
      {:ok, response} ->
        response
      {:error, reason} ->
        IO.inspect(reason, label: "Error")
        {:error, reason}
    end

    dbg(config_response)
    config = Map.get(config_response, "info")

    updated_config = Map.put(config, "leds", socket.assigns.leds)

    dbg(updated_config)

    payload = %{
      "command" => "config",
      "subcommand" => "setconfig",
      "config" => updated_config,
      "tan" => 1
    }

    #save Hyperion config
    save = case Hyperion.post_json(payload) do
      {:ok, response} ->
        response
      {:error, reason} ->
        IO.inspect(reason, label: "Error")
        {:error, reason}
    end

    dbg(save)
    dbg(socket.assigns.selected)
    dbg(instance)

    {:noreply, socket
      #|> assign(:selected, String.to_integer(instance))
      #|> push_event("select-stripe", %{})
    }
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

    payload = %{
      "command" => "instance",
      "subcommand" => "switchTo",
      "instance" => String.to_integer(value["select"])
    }

    #dbg(payload)

    switch = case Hyperion.post_json(payload) do
      {:ok, response} ->
        #IO.inspect(response, label: "Response")
        #dbg(response["info"])
        #{:ok, stream(socket, :hyperionserverinfo, response["instance"])}
        #{:ok, assign(socket, :serverinfo, response["info"])}
        {:ok, response["info"]}
      {:error, reason} ->
        IO.inspect(reason, label: "Error")
        {:error, reason}
    end

    payload = %{
      "command" => "config",
      "subcommand" => "getconfig",
      "tan" => 1
    }

    current_config = case Hyperion.post_json(payload) do
      {:ok, response} ->
        response
      {:error, reason} ->
        IO.inspect(reason, label: "Error")
        %{"error" => reason, "leds" => []}
    end

    #dbg(current_config)


    leds = case current_config["success"] do
      true ->
        info = Map.get(current_config, "info", %{})
        Map.get(info, "leds", [])
      false -> []
    end

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
      |> assign(:current_config, current_config)
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

    leds_pixel = Enum.map(socket.assigns.leds, fn led ->
      {:ok, led_pixel} = VisualsAdmin.Hyperion.get_led_pixel(led, size, socket.assigns.position)
      led_pixel
    end)

    dbg(leds_pixel)

    led_width = if length(leds_pixel) > 0 do
      leds_pixel |> hd() |> Map.get(:width)
    else
      0
    end

    led_height = if length(leds_pixel) > 0 do
      leds_pixel |> hd() |> Map.get(:height)
    else
      0
    end

    IO.puts("size: #{inspect(size)}")
    {:noreply, socket
      |> assign(:size, size)
      |> assign(:leds_pixel, leds_pixel)
      |> assign(:led_width, led_width)
      |> assign(:led_height, led_height)
      |> push_event("resize-window", %{})
    }
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

  def handle_event("points_messured", %{"distance" => distance, "verticies" => verticies}, socket) do
    dbg("points_messured")
    dbg(distance)
    dbg(verticies)

    max_size = socket.assigns.point_messure/length(socket.assigns.leds)

    dbg(verticies)

    start_coords = { parseFloat(Map.get(verticies, "x1")), parseFloat(Map.get(verticies, "y1")) }
    end_coords = { parseFloat(Map.get(verticies, "x2")), parseFloat(Map.get(verticies, "y2")) }

    dbg(start_coords)
    dbg(end_coords)

    leds_interpolate = interpolate_coords(start_coords, end_coords, length(socket.assigns.leds), max_size)
    #dbg(leds_interpolate)

    #################################
    leds_pixel_calc = Enum.map(leds_interpolate, fn led ->
      vmax = led.vmin + max_size
      hmax = led.hmin + max_size
      #dbg(led)
      %{
        hmax: hmax,
        hmin: led.hmin,
        vmax: vmax,
        vmin: led.vmin
      }
    end)

    leds = Enum.map(leds_pixel_calc, fn led ->
      {:ok, led_coordinates} = VisualsAdmin.Hyperion.get_led_coordinates(led, socket.assigns.size, socket.assigns.position)

        #dbg(led_coordinates)

      %{
        "hmax" => led_coordinates.hmax,
        "hmin" => led_coordinates.hmin,
        "vmax" => led_coordinates.vmax,
        "vmin" => led_coordinates.vmin
      }

    end)
    #####################################################################

    {:noreply, socket
     |> assign(:point_messure, distance)
     |> assign(:verticies, verticies)
     |> assign(:leds_pixel, leds_interpolate)
     |> assign(:leds, leds)
    }
  end

  defp interpolate_coords({x1, y1}, {x2, y2}, num_divs, max_size) do
    step_x = (x2 - x1) / (num_divs - 1)
    step_y = (y2 - y1) / (num_divs - 1)

    dbg({x1, y1})
    dbg({x2, y2})

    #for i <- 0..(num_divs - 1) do
    #  {x1 + i * step_x, y1 + i * step_y}
    #end

    #for i <- 0..(num_divs - 1) do
    #  %{:vmin => x1 + i * step_x, :hmin => y1 + i * step_y, :vmax => x1 + i * step_x + max_size, :hmax => y1 + i * step_y + max_size }
    #end

    for i <- 0..(num_divs - 1) do
      %{:vmin => y1 + i * step_y, :hmin => x1 + i * step_x, :vmax => y1 + i * step_y + max_size, :hmax => x1 + i * step_x + max_size }
    end

  end

  def parseFloat(string) do
    case Float.parse(string) do
      {value, str_rest} -> value
      _ -> 0
    end
  end

end
