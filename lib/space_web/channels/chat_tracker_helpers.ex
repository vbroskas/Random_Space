defmodule SpaceWeb.ChatTrackerHelpers do
  alias SpaceWeb.ChatTracker

  def list_users(topic) do
    # ChatTracker.list(topic)
    result = ChatTracker.list(topic)
    IO.inspect(result)
  end
end
