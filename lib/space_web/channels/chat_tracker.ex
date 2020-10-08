defmodule SpaceWeb.ChatTracker do
  @behaviour Phoenix.Tracker
  alias Space.IntervalServer

  require Logger

  @doc """
  track all clients connected to each "space:interval"
  """

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor
    }
  end

  def start_link(opts) do
    opts =
      opts
      |> Keyword.put(:name, __MODULE__)
      |> Keyword.put(:pubsub_server, Space.PubSub)

    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)
    {:ok, %{pubsub_server: server}}
  end

  @doc """
  on each leaves event make call to genserver
  """

  def handle_diff(diff, state) do
    for {topic, {joins, leaves}} <- diff do
      <<"space:", sub_topic::binary>> = topic

      for {_key, _meta} <- leaves do
        # call genserver for this interval to see if it should be shutdown
        IntervalServer.check_room_status(sub_topic)
      end

      for {key, meta} <- joins do
        IO.puts("#{sub_topic}~~presence join: key \"#{key}\" with meta #{inspect(meta)}")
        # Phoenix.PubSub.direct_broadcast!(state.node_name, state.pubsub_server, topic, msg)
      end
    end

    {:ok, state}
  end

  @doc """
  track user_id and their role
  """
  def track(%{channel_pid: pid, topic: topic, assigns: %{user_id: user_id, username: username}}) do
    metadata = %{
      online_at: DateTime.utc_now(),
      user_id: user_id,
      username: username
    }

    Phoenix.Tracker.track(__MODULE__, pid, topic, user_id, metadata)
  end

  def list(topic) do
    Phoenix.Tracker.list(__MODULE__, topic)
  end
end
