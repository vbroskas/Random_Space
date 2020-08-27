defmodule SpaceWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](http://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :space,
    pubsub_server: Space.PubSub

  # def fetch(_topic, entries) do
  #   %{
  #     "room" => %{"room" => count_presences(entries, "viewers")}
  #     # "users" => %{"users" => count_presences(entries, "users")}
  #   }

  #   # for {key, %{metas: metas}} <- presences, into: %{} do
  #   #   {key, %{metas: metas, user: users[String.to_integer(key)]}}
  #   # end
  # end

  # defp count_presences(entries, key) do
  #   case get_in(entries, [key, :metas]) do
  #     nil -> 0
  #     metas -> metas
  #   end
  # end
end
