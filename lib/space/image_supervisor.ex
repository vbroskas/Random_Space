defmodule Space.ImageSupervisor do
  use DynamicSupervisor

  def start_link(arg) do
    IO.puts("starting Image supervisor...")
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_image_server_instance(client_id) do
    DynamicSupervisor.start_child(__MODULE__, {Space.IntervalStash, client_id})

    DynamicSupervisor.start_child(__MODULE__, {Space.SpaceServer, client_id})
  end
end
