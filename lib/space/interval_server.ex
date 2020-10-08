defmodule Space.IntervalServer do
  # @name :space_server
  use GenServer, restart: :transient
  alias SpaceWeb.ChatTracker

  defmodule State do
    defstruct interval: ""
  end

  def check_room_status(interval) do
    GenServer.cast(
      {:via, Registry, {SpaceRegistry, "space_server:#{interval}"}},
      {:check_room_status, interval}
    )
  end

  def start_link(interval) do
    IO.puts("starting up space genserver for interval #{interval}")
    GenServer.start_link(__MODULE__, interval, name: process_interval(interval))
  end

  def init(interval) do
    state = %State{interval: interval}
    get_new_image(interval)
    broadcast_interval(interval)
    {:ok, state, {:continue, :refresh}}
  end

  # server callback functions--------------------------
  def handle_continue(:refresh, state) do
    sched_refresh(state.interval)
    {:noreply, state}
  end

  def handle_cast({:check_room_status, interval}, state) do
    if ChatTracker.list("space:#{interval}") == [] do
      IO.puts("KILLING Server for #{interval}!")
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  @doc """
  use handle_info to process our refresh loop
  """
  def handle_info(:refresh, state) do
    get_new_image(state.interval)
    sched_refresh(state.interval)
    {:noreply, state}
  end

  defp sched_refresh(interval) do
    Process.send_after(
      self(),
      :refresh,
      :timer.seconds(interval)
    )
  end

  defp broadcast_interval(interval) do
    SpaceWeb.Endpoint.broadcast!("space:#{interval}", "new_interval", %{
      "interval" => interval
    })
  end

  defp update_url_in_stash(url, interval) do
    Space.IntervalStash.update({:via, Registry, {SpaceRegistry, "Stash-#{interval}"}}, url)
  end

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
        url =
          Poison.Parser.parse!(body, %{})
          |> get_in(["url"])

        # set url in the agent for this interval
        update_url_in_stash(url, interval)
        SpaceWeb.Endpoint.broadcast!("space:#{interval}", "new_url", %{"url" => url})

      {:error, %HTTPoison.Error{id: nil, reason: :timeout}} ->
        IO.puts("****POISON DEAD****")
    end
  end

  defp process_interval(interval) do
    {:via, Registry, {SpaceRegistry, "space_server:#{interval}"}}
  end
end
