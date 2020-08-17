defmodule SpaceWeb.RoomChannel do
  use Phoenix.Channel
  # intercept ["new_msg"]

  def join("room:" <> uuid, _message, socket) do
    IO.puts("Joined channel....#{uuid}")
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("change_interval", %{"interval" => interval, "client_id" => client_id}, socket) do
    # send interval change request to genserver
    interval = interval |> String.to_integer()
    Space.SpaceServer.set_new_interval(interval, client_id)
    {:noreply, socket}
  end

  def handle_in("create_server", %{"client_id" => client_id}, socket) do
    IO.puts("creating server for..#{client_id}")
    # create genserver instance
    Space.ImageSupervisor.create_image_server_instance(client_id)
    {:noreply, socket}
  end
end
