defmodule Space.IntervalStash do
  use Agent

  def start_link(interval) do
    Agent.start_link(fn -> "" end, name: process_client_id(interval))
  end

  defp process_client_id(interval) do
    {:via, Registry, {SpaceRegistry, "Stash-#{interval}"}}
  end

  def get(name) do
    Agent.get(name, fn url -> url end)
  end

  def update(name, new_url) do
    Agent.update(name, fn _state -> new_url end)
  end
end
