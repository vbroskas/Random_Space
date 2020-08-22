defmodule Space.SpaceServer do
  # @name :space_server
  use GenServer, restart: :transient

  defmodule State do
    defstruct client_id: "", timer: nil, current_chat: nil
  end

  def start_link(client_id) do
    IO.puts("starting up space genserver for client #{client_id}")
    GenServer.start_link(__MODULE__, client_id, name: process_client_id(client_id))
  end

  defp process_client_id(client_id) do
    {:via, Registry, {ImageRegistry, "#{client_id}"}}
  end

  def set_new_interval(interval, client_id) do
    GenServer.cast(
      process_client_id(client_id),
      {:set_interval, interval, client_id}
    )
  end

  def set_timer(timer, client_id) do
    GenServer.cast(
      process_client_id(client_id),
      {:set_timer, timer}
    )
  end

  # server callback functions--------------------------
  def init(client_id) do
    interval = get_interval_from_stash(client_id)
    state = %State{client_id: client_id, current_chat: interval}
    # get first image
    get_new_image(client_id)
    # send interval to client
    broadcast_interval(interval, client_id)
    # make call to begin timer loop
    sched_refresh(interval, client_id)

    {:ok, state}
  end

  @doc """
  handle cast to set a new timer
  """
  def handle_cast({:set_timer, timer}, state) do
    # set new timer in state
    state = %{state | timer: timer}
    {:noreply, state}
  end

  @doc """
  handle cast to set a new interval
  """
  def handle_cast({:set_interval, interval, client_id}, state) do
    # set new interval in Agent
    update_interval_in_stash(client_id, interval)
    # cancel current timer
    Process.cancel_timer(state.timer)
    # send interval to client
    broadcast_interval(interval, state.client_id, state)
    # update chat room in state
    state = %{state | current_chat: interval}
    # send new img to client
    get_new_image(state.client_id)
    # restart loop with new timer
    sched_refresh(interval, client_id)

    {:noreply, state}
  end

  @doc """
  use handle_info to process our refresh loop
  "Another use case for handle_info/2 is to perform periodic work, with the help of Process.send_after/4:"
  https://hexdocs.pm/elixir/GenServer.html#module-receiving-regular-messages
  """
  def handle_info(:refresh, state) do
    get_new_image(state.client_id)

    interval = get_interval_from_stash(state.client_id)

    sched_refresh(interval, state.client_id)

    {:noreply, state}
  end

  defp sched_refresh(interval, client_id) do
    [{pid, _value}] = Registry.lookup(ImageRegistry, "#{client_id}")
    IO.inspect(pid)

    timer =
      Process.send_after(
        pid,
        :refresh,
        :timer.seconds(interval)
      )

    set_timer(timer, client_id)
  end

  defp update_interval_in_stash(client_id, interval) do
    Space.IntervalStash.update({:via, Registry, {ImageRegistry, "Stash-#{client_id}"}}, interval)
  end

  defp get_interval_from_stash(client_id) do
    Space.IntervalStash.get({:via, Registry, {ImageRegistry, "Stash-#{client_id}"}})
  end

  defp broadcast_interval(interval, client_id, state) do
    IO.puts("BROAD 3")
    # if chat channel stored in state, leave current channel & join channel for new interval
    # leave curernt channel
    # SpaceWeb.Endpoint.broadcast!("chat:#{state.current_chat}", "change_chat", %{
    #   "new_chat" => interval,
    #   "old_chat" => state.current_chat
    # })

    SpaceWeb.Endpoint.broadcast!("room:#{client_id}", "new_interval", %{
      "interval" => interval,
      "client_id" => client_id
    })
  end

  defp broadcast_interval(interval, client_id) do
    IO.puts("BROAD 2")

    SpaceWeb.Endpoint.broadcast!("room:#{client_id}", "new_interval", %{
      "interval" => interval,
      "client_id" => client_id
    })
  end

  defp get_new_image(client_id) do
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

    SpaceWeb.Endpoint.broadcast!("room:#{client_id}", "new_url", %{"url" => url})
  end
end
