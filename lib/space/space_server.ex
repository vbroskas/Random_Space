defmodule Space.SpaceServer do
  @name :space_server
  use GenServer

  defmodule State do
    defstruct interval: 0
  end

  def start_link(interval \\ 5) do
    IO.puts("STARTING up space genserver....")
    state = %State{interval: interval}
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def set_new_interval(time) do
    GenServer.cast(@name, {:set_interval, time})
  end

  # server callback functions--------------------------
  def init(state) do
    sched_refresh(state.interval)
    {:ok, state}
  end

  @doc """
  handle the cast to set a new interval
  """
  def handle_cast({:set_interval, time}, state) do
    IO.puts("Hit handle_cast :set_interval")
    # receive request to set a new interval, and update :interval in our State struct
    new_state = %{state | interval: time}
    {:noreply, new_state}
  end

  @doc """
  use handle_info to process our refresh loop
  "Another use case for handle_info/2 is to perform periodic work, with the help of Process.send_after/4:"
  https://hexdocs.pm/elixir/GenServer.html#module-receiving-regular-messages
  """
  def handle_info(:refresh, state) do
    IO.puts("Processing handle_info :refresh call")
    # we could call get_new_image() either here or in our sched_refresh() call...
    get_new_image()
    sched_refresh(state.interval)
    {:noreply, state}
  end

  defp sched_refresh(interval) do
    IO.puts("In sched ref....interval currently set to: #{interval}(seconds)")
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

    IO.puts("NEW URL IS>>>>>>>>>>  #{url}")
  end
end
