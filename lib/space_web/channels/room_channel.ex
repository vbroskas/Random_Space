defmodule SpaceWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    IO.puts("Joined channel....")
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_out("new_msg", payload, socket) do
    IO.puts("hit handle_out...")
    {:noreply, socket}
  end
end
