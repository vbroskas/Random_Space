defmodule SpaceWeb.SpaceChannel do
  use Phoenix.Channel
  alias SpaceWeb.Presence

  def join("space:" <> interval, _payload, socket) do
    IO.puts("Joined space....#{interval}")

    # start presence
    send(self(), {:after_join, interval})

    {:ok, %{reply: "Joined room: #{interval}"}, socket}
  end

  def join("space:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body, client_id: socket.assigns.client_id})
    {:noreply, socket}
  end

  def handle_in("create_server", %{"interval" => interval}, socket) do
    case Registry.lookup(SpaceRegistry, "space_server:#{interval}") do
      [] ->
        IO.puts("creating server for..#{interval}")
        # convert interval to integer
        interval = interval |> String.to_integer()
        Space.ImageSupervisor.start_interval_server(interval)
        {:noreply, socket}

      [{_pid, _value}] ->
        IO.puts("ALREADY RUNNING")
        # send interval back to client
        SpaceWeb.Endpoint.broadcast!("space:#{interval}", "new_interval", %{
          "interval" => interval
        })

        # grab current image url from storage
        url = get_url_from_stash(interval)
        IO.puts("GOT URL FROM STASH")
        # broadcast to client who just connected
        SpaceWeb.Endpoint.broadcast!("space:#{interval}", "new_url", %{"url" => url})

        {:noreply, socket}
    end

    # {:noreply, socket}
  end

  def handle_info({:after_join, interval}, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.client_id, %{
        client_id: socket.assigns.client_id
      })

    # {:ok, _} = Presence.track(self(), "space:#{interval}", "room", %{room: "space:#{interval}"})

    IO.inspect(Presence.list(socket))

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
  end

  defp get_url_from_stash(interval) do
    Space.IntervalStash.get({:via, Registry, {SpaceRegistry, "Stash-#{interval}"}})
  end
end
