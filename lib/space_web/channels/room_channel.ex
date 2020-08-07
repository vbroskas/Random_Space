defmodule SpaceWeb.RoomChannel do
  use Phoenix.Channel
  # intercept ["new_msg"]

  def join("room:lobby", _message, socket) do
    IO.puts("Joined channel....")
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("change_interval", %{"interval" => interval}, socket) do
    # send interval change request to genserver
    interval
    |> String.to_integer()
    |> Space.SpaceServer.set_new_interval()

    {:noreply, socket}
  end
end
