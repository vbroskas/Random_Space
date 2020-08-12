defmodule Space.ImageSupervisor do
  use Supervisor

  def start_link(_args \\ nil) do
    IO.puts("starting Services supervisor...")
    # start_link spawns a supervisor process and LINKS it to the process that calls start_link()
    # start_link(module, init_arg, options \\ [])...__MODULE__ is our callback module
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # init is where we tell the Supervisor process what children processes it needs to monitor
    # when a child process is started, it needs to be linked to the supervisor so the supervisor can detect a crash
    # as a default, the supervisor process assumes a child process defines a start_link() function...
    children = [Space.SpaceServer, {Phoenix.PubSub, name: :my_pubsub}]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
