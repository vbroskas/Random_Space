defmodule SpaceWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](http://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :space,
    pubsub_server: Space.PubSub

  def track_user_join(socket, user) do
    SpaceWeb.Presence.track(socket, user.id, %{
      typing: false,
      first_name: user.first_name,
      user_id: user.id
    })
  end
end
