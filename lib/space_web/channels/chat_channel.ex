defmodule SpaceWeb.ChatChannel do
  use Phoenix.Channel
  alias SpaceWeb.Presence
  # intercept ["change_chat"]

  def join("chat:" <> interval, payload, socket) do
    IO.puts("Joined chat for interval...#{interval}")
    socket = assign(socket, client: payload["client"])
    send(self(), :after_join)
    {:ok, %{reply: "Joined chat: #{interval}"}, socket}
  end

  def join("chat:" <> _private_chat_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.client, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end
