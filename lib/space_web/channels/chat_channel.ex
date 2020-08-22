defmodule SpaceWeb.ChatChannel do
  use Phoenix.Channel
  # intercept ["change_chat"]

  def join("chat:" <> interval, payload, socket) do
    IO.puts("Joined chat for interval...#{interval}")
    socket = assign(socket, client: payload["client"])
    {:ok, %{reply: "Joined chat: #{interval}"}, socket}
  end

  def join("chat:" <> _private_chat_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    IO.puts(" G O T NEW M S G")
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end
