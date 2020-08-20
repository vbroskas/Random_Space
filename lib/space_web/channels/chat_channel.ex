defmodule SpaceWeb.ChatChannel do
  use Phoenix.Channel
  # intercept ["new_msg"]

  def join("chat:" <> interval, _message, socket) do
    IO.puts("Joined chat for interval...#{interval}")
    {:ok, %{reply: "Joined room: #{interval}"}, socket}
  end

  def join("chat:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end
