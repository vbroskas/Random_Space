defmodule SpaceWeb.SpaceChannel do
  use Phoenix.Channel
  alias SpaceWeb.Presence
  alias SpaceWeb.ChatTracker

  def join("space:" <> interval, _payload, socket) do
    IO.puts("Joined space....#{interval}")
    # start presence
    send(self(), {:after_join, interval})
    {:ok, %{reply: "Joined room: #{interval}"}, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{
      body: body,
      username: socket.assigns.username,
      user_id: socket.assigns.user_id
    })

    {:noreply, socket}
  end

  def handle_info(
        {:after_join, interval},
        %{channel_pid: pid, topic: topic, assigns: %{user_id: user_id, username: username}} =
          socket
      ) do
    # connect to agent & genserver for this interval
    check_room_status(interval, socket)

    # Pubsub tracker--
    {:ok, _} = ChatTracker.track(socket)

    # Presence tracker--
    metadata = %{
      online_at: DateTime.utc_now(),
      user_id: user_id,
      username: username
    }

    {:ok, _} = Presence.track(pid, topic, user_id, metadata)
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  defp get_url_from_stash(interval) do
    Space.IntervalStash.get({:via, Registry, {SpaceRegistry, "Stash-#{interval}"}})
  end

  defp check_room_status(interval, socket) do
    case Registry.lookup(SpaceRegistry, "space_server:#{interval}") do
      # no current server running for this interval
      [] ->
        interval
        |> String.to_integer()
        |> Space.ImageSupervisor.start_interval_server()

        {:noreply, socket}

      # server already running for this interval
      [{_pid, _value}] ->
        SpaceWeb.Endpoint.broadcast!("space:#{interval}", "new_interval", %{
          "interval" => interval
        })

        url = get_url_from_stash(interval)
        SpaceWeb.Endpoint.broadcast!("space:#{interval}", "new_url", %{"url" => url})

        {:noreply, socket}
    end
  end
end
