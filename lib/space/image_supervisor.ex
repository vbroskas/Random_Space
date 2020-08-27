defmodule Space.ImageSupervisor do
  use DynamicSupervisor

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(arg) do
    IO.puts("starting Image supervisor...")
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @spec init(any) ::
          {:ok,
           %{
             extra_arguments: [any],
             intensity: non_neg_integer,
             max_children: :infinity | non_neg_integer,
             period: pos_integer,
             strategy: :one_for_one
           }}
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # def create_image_server_instance(client_id) do
  #   DynamicSupervisor.start_child(__MODULE__, {Space.IntervalStash, client_id})
  #   DynamicSupervisor.start_child(__MODULE__, {Space.SpaceServer, client_id})
  # end

  def start_interval_server(interval) do
    # start stash for this interval
    DynamicSupervisor.start_child(__MODULE__, {Space.IntervalStash, interval})
    # start server for this interval
    case DynamicSupervisor.start_child(__MODULE__, {Space.IntervalServer, interval}) do
      {:ok, _pid} -> IO.puts("STARTED CHILD")
      {:error, {:already_started, _pid}} -> IO.puts("CHILD RUNNING")
      error -> IO.inspect(error.message)
    end
  end
end
