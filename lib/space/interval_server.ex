defmodule Space.IntervalServer do
  # @name :space_server
  use GenServer, restart: :transient
  alias SpaceWeb.ChatTracker

  defmodule State do
    defstruct interval: ""
  end

  def start_link(interval) do
    IO.puts("starting up space genserver for interval #{interval}")
    GenServer.start_link(__MODULE__, interval, name: process_interval(interval))
  end

  def init(interval) do
    state = %State{interval: interval}
    broadcast_interval(interval)
    {:ok, state, {:continue, :refresh}}
  end

  @doc """
  check if any users still subscribed to the topic for this servers interval
  """
  def check_room_status(interval) do
    GenServer.cast(
      {:via, Registry, {SpaceRegistry, "space_server:#{interval}"}},
      {:check_room_status, interval}
    )
  end

  # server callback functions--------------------------

  def handle_continue(:refresh, state) do
    get_new_image(state.interval)

    SpaceWeb.Endpoint.broadcast!("space:#{state.interval}", "countdown_tick", %{
      "time" => state.interval
    })

    run_countdown(state.interval - 1)
    {:noreply, state}
  end

  def handle_cast({:check_room_status, interval}, state) do
    if ChatTracker.list("space:#{interval}") == [] do
      IO.puts("KILLING Server & Agent for #{interval}!")
      Agent.stop({:via, Registry, {SpaceRegistry, "Stash-#{interval}"}})
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  @doc """
  broadcast coutdown ticker, and new image url when ticker hits 0
  """
  def handle_info({:countdown_tick, time_remaining}, state) do
    case time_remaining do
      0 ->
        get_new_image(state.interval)

        SpaceWeb.Endpoint.broadcast!("space:#{state.interval}", "countdown_tick", %{
          "time" => state.interval
        })

        run_countdown(state.interval - 1)

      _ ->
        SpaceWeb.Endpoint.broadcast!("space:#{state.interval}", "countdown_tick", %{
          "time" => time_remaining
        })

        run_countdown(time_remaining - 1)
    end

    {:noreply, state}
  end

  defp run_countdown(time_remaining) do
    Process.send_after(
      self(),
      {:countdown_tick, time_remaining},
      :timer.seconds(1)
    )
  end

  @doc """
  send interval back to client
  """
  defp broadcast_interval(interval) do
    SpaceWeb.Endpoint.broadcast!("space:#{interval}", "new_interval", %{
      "interval" => interval
    })
  end

  @doc """
  put current image url in the Agent for this interval
  """
  defp update_url_in_stash(url, interval) do
    Space.IntervalStash.update({:via, Registry, {SpaceRegistry, "Stash-#{interval}"}}, url)
  end

  @doc """
  Select a random day between now() and beginning of time, and query NASA api with that day.
  """
  defp get_new_image(interval) do
    today = DateTime.utc_now() |> DateTime.to_unix()
    new_random_day = Enum.random(803_260_800..today)
    new_random_date = DateTime.from_unix!(new_random_day) |> DateTime.to_date()

    request_url =
      "https://api.nasa.gov/planetary/apod?api_key=Tp4IT2WFMoc2dKArhDgwKjTMWhoEo1nnv5ayl3Vh&date=#{
        new_random_date
      }"

    case HTTPoison.get(request_url) do
      {:ok, %{status_code: 200, body: body}} ->
        url = parse_url(body)
        explanation = parse_explanation(body)

        # set url in the agent for this interval
        update_url_in_stash(url, interval)

        SpaceWeb.Endpoint.broadcast!("space:#{interval}", "new_url", %{
          "url" => url,
          "explanation" => explanation
        })

      {:error, %HTTPoison.Error{id: nil, reason: :timeout}} ->
        IO.puts("****POISON DEAD****")
    end
  end

  @doc """
  register the name for this server with the assocated interval
  """
  defp process_interval(interval) do
    {:via, Registry, {SpaceRegistry, "space_server:#{interval}"}}
  end

  @doc """
  pull url out of api query body
  """
  defp parse_url(body) do
    Poison.Parser.parse!(body, %{})
    |> get_in(["url"])
  end

  @doc """
  pull description out of api query body
  """
  defp parse_explanation(body) do
    Poison.Parser.parse!(body, %{})
    |> get_in(["explanation"])
  end
end
