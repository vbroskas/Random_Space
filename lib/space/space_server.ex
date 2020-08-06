defmodule Space.SpaceServer do
  @name :space_server
  use GenServer
  alias SpaceWeb.RoomChannel
  alias SpaceWeb.UserSocket

  defmodule State do
    defstruct interval: 0
  end

  def start_link(interval \\ 5) do
    IO.puts("starting up space genserver....")
    state = %State{interval: interval}
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def set_new_interval(interval) do
    GenServer.cast(@name, {:set_interval, interval})
  end

  # server callback functions--------------------------
  def init(state) do
    # on initial page load, generate & send initial image along with starting interval
    get_new_image()
    SpaceWeb.Endpoint.broadcast!("room:lobby", "new_interval", %{"interval" => state.interval})

    # make call to begin loop
    sched_refresh(state.interval)
    {:ok, state}
  end

  @doc """
  handle the cast to set a new interval
  """
  def handle_cast({:set_interval, interval}, state) do
    new_state = %{state | interval: interval}
    SpaceWeb.Endpoint.broadcast!("room:lobby", "new_interval", %{"interval" => interval})
    # on interval change send fresh image
    get_new_image()
    {:noreply, new_state}
  end

  @doc """
  use handle_info to process our refresh loop
  "Another use case for handle_info/2 is to perform periodic work, with the help of Process.send_after/4:"
  https://hexdocs.pm/elixir/GenServer.html#module-receiving-regular-messages
  """
  def handle_info(:refresh, state) do
    # we could call get_new_image() either here or in our sched_refresh() call...
    get_new_image()
    sched_refresh(state.interval)
    {:noreply, state}
  end

  defp sched_refresh(interval) do
    # IO.puts("In sched ref....interval currently set to: #{interval}(seconds)")
    # send_after(dest, msg, time, opts \\ [])
    # https://hexdocs.pm/elixir/Process.html#send_after/4
    Process.send_after(self(), :refresh, :timer.seconds(interval))
  end

  defp get_new_image do
    today = DateTime.utc_now() |> DateTime.to_unix()
    new_random_day = Enum.random(803_260_800..today)
    new_random_date = DateTime.from_unix!(new_random_day) |> DateTime.to_date()

    request_url =
      "https://api.nasa.gov/planetary/apod?api_key=Tp4IT2WFMoc2dKArhDgwKjTMWhoEo1nnv5ayl3Vh&date=#{
        new_random_date
      }"

    {:ok, %{status_code: 200, body: body}} = HTTPoison.get(request_url)

    url =
      Poison.Parser.parse!(body, %{})
      |> get_in(["url"])

    SpaceWeb.Endpoint.broadcast!("room:lobby", "new_url", %{"url" => url})
  end
end
