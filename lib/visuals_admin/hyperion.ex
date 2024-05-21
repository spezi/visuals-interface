defmodule VisualsAdmin.Hyperion do
  @moduledoc """
  The Hyperion context.
  """

  #import Ecto.Query, warn: false
  #alias VisualsAdmin.Repo

  alias VisualsAdmin.Hyperion.Mapping

  require Logger

  def fetch_and_print_pretty_json(url) do
    case HTTPoison.post(url, %{"Content-Type" => "application/json"}) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, json} ->
            IO.puts Jason.encode_to_iodata!(json, pretty: true)

          {:error, decode_error} ->
            IO.puts "Failed to decode JSON: #{inspect(decode_error)}"
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts "HTTP request failed with status #{status_code}: #{body}"

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts "HTTP request failed: #{inspect(reason)}"
    end
  end




  def post_json(url, payload) do
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(payload)

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, json} ->
            #Logger.info("Request successful: #{Jason.encode_to_iodata!(json, pretty: true)}")
            {:ok, json}

          {:error, decode_error} ->
            Logger.error("Failed to decode JSON response: #{inspect(decode_error)}")
            {:error, :invalid_json}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        Logger.error("Request failed with status #{status_code}: #{response_body}")
        {:error, {:http_error, status_code, response_body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTP request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def coordinate_to_pixel(point, max_pixel) do
     point * max_pixel
  end

  def pixel_to_coordinate(pixel, max_pixel) do
    #dbg(pixel)
    #dbg(max_pixel)
    pixel/max_pixel
  end

  def led_width_or_height(min,max) do
    max - min
  end

  def get_led_pixel(led, size, position) do
    #Logger.info("pixel size: #{inspect(pixel_size)}")
    #Logger.info("LED: #{inspect(led)}")

    #Logger.info("LED: #{inspect(led)}")
    #Logger.info("size: #{inspect(size)}")

    led_pixel = %{
      hmax: coordinate_to_pixel(led["hmax"], size.width),
      hmin: coordinate_to_pixel(led["hmin"], size.width),
      vmax: coordinate_to_pixel(led["vmax"], size.height),
      vmin: coordinate_to_pixel(led["vmin"], size.height),
      width: led_width_or_height(
        coordinate_to_pixel(led["hmin"], size.width),
        coordinate_to_pixel(led["hmax"], size.width)
      ),
      height: led_width_or_height(
        coordinate_to_pixel(led["vmin"], size.height),
        coordinate_to_pixel(led["vmax"], size.height)
      ),
    }

    #Logger.info("LED: #{inspect(led_pixel)}")

    {:ok, led_pixel}

  end

  def get_led_coordinates(led, size, position) do
    #Logger.info("pixel size: #{inspect(pixel_size)}")
    #Logger.info("LED: #{inspect(led)}")

    #Logger.info("LED: #{inspect(led)}")
    #Logger.info("size: #{inspect(size)}")
    #Logger.info("POSITION: #{inspect(position)}")

    led_pixel = %{
      hmax: pixel_to_coordinate(led.hmax, size.width),
      hmin: pixel_to_coordinate(led.hmin, size.width),
      vmax: pixel_to_coordinate(led.vmax, size.height),
      vmin: pixel_to_coordinate(led.vmin, size.height)
    }

    #Logger.info("LED: #{inspect(led_pixel)}")

    {:ok, led_pixel}

  end

  def place_led_wrapper(leds, size, position) do

    first_led = List.last(leds)
    last_led = List.first(leds)
    dbg(first_led)
    dbg(last_led)

    case first_led do
      nil -> nil
      _ ->
        {from, to} = cond do
          first_led["hmax"] == last_led["hmax"] ->
            from = {
              coordinate_to_pixel(first_led["vmin"], size.height),
              coordinate_to_pixel(first_led["hmin"], size.width)
            }
            to = {
              coordinate_to_pixel(last_led["vmax"], size.height),
              coordinate_to_pixel(last_led["hmax"], size.width)
            }
            { top, left } = from
            { bottom, right } = to
            {from, to}
          first_led["hmax"] != last_led["hmax"] ->
            from = {
              coordinate_to_pixel(last_led["vmin"], size.height),
              coordinate_to_pixel(last_led["hmin"], size.width)
            }
            to = {
              coordinate_to_pixel(first_led["vmax"], size.height),
              coordinate_to_pixel(first_led["hmax"], size.width)
            }
            { top, left } = from
            { bottom, right } = to
            {from, to}
        end
        dbg(from)
        dbg(to)

        "top: #{elem(from, 0)}px; left: #{elem(from, 1)}px; width: #{elem(to, 1) - elem(from, 1)}px; height: #{elem(to, 0) - elem(from, 0)}px;"
    end
    #from = coordinate_to_pixel(first_led["vmin"], size.height)
    #from = {coordinate_to_pixel(first_led, size.width), coordinate_to_pixel(first_led, size.height)}
    #to = {coordinate_to_pixel(last_led, size.width), coordinate_to_pixel(last_led, size.height)}
    #dbg(from)

  end

  def parse_to_number(string) do
    case Float.parse(string) do
      {float, _} -> float
      nil -> parse_integer(string)
    end
  end

  defp parse_integer(string) do
    case Integer.parse(string) do
      {integer, _} -> integer
      nil -> {:error, "Invalid number format"}
    end
  end



  @doc """
  Returns the list of mappings.

  ## Examples

      iex> list_mappings()
      [%Mapping{}, ...]

  """
  #def list_mappings do
  #  raise "TODO"
  #end

  @doc """
  Gets a single mapping.

  Raises if the Mapping does not exist.

  ## Examples

      iex> get_mapping!(123)
      %Mapping{}

  """
  #def get_mapping!(id), do: raise "TODO"

  @doc """
  Creates a mapping.

  ## Examples

      iex> create_mapping(%{field: value})
      {:ok, %Mapping{}}

      iex> create_mapping(%{field: bad_value})
      {:error, ...}

  """
  #def create_mapping(attrs \\ %{}) do
  #  raise "TODO"
  #end

  @doc """
  Updates a mapping.

  ## Examples

      iex> update_mapping(mapping, %{field: new_value})
      {:ok, %Mapping{}}

      iex> update_mapping(mapping, %{field: bad_value})
      {:error, ...}

  """
  #def update_mapping(%Mapping{} = mapping, attrs) do
  #  raise "TODO"
  #end

  @doc """
  Deletes a Mapping.

  ## Examples

      iex> delete_mapping(mapping)
      {:ok, %Mapping{}}

      iex> delete_mapping(mapping)
      {:error, ...}

  """
  #def delete_mapping(%Mapping{} = mapping) do
  #  raise "TODO"
  #end

  @doc """
  Returns a data structure for tracking mapping changes.

  ## Examples

      iex> change_mapping(mapping)
      %Todo{...}

  """
  #def change_mapping(%Mapping{} = mapping, _attrs \\ %{}) do
  #  raise "TODO"
  #end
end
