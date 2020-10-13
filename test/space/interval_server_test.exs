defmodule Space.IntervalServerTest do
  alias Space.IntervalServer
  import ExUnit.CaptureLog
  alias Space.IntervalStash
  alias SpaceWeb.SpaceChannel
  use ExUnit.Case

  setup do
    :ok
  end

  describe "test check_room_status from space_channel" do
    test "successful lookup of a running server" do
      {:ok, pid} = IntervalServer.start_link(20)
      assert Registry.lookup(SpaceRegistry, "space_server:20") == [{pid, nil}]
    end

    test "successful lookup of a  non-running server" do
      assert Registry.lookup(SpaceRegistry, "space_server:20") == []
    end
  end
end
