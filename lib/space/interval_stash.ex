defmodule Space.IntervalStash do
  use Agent

  def start_link(client_id) do
    Agent.start_link(fn -> 15 end, name: process_client_id(client_id))
  end

  defp process_client_id(client_id) do
    {:via, Registry, {ImageRegistry, "Stash-#{client_id}"}}
  end

  def get(name) do
    Agent.get(name, fn state -> state end)
  end

  def update(name, new_interval) do
    Agent.update(name, fn _state -> new_interval end)
  end
end
