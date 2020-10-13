defmodule Space.IntervalStashTest do
  import ExUnit.CaptureLog
  alias Space.IntervalStash
  alias SpaceWeb.SpaceChannel
  alias Space.IntervalServer
  use ExUnit.Case

  setup do
    :ok
  end

  # describe "check that stash update and get works" do
  #   test "check stash insert" do
  #     IntervalStash.start_link(25)
  #     IntervalStash.update({:via, Registry, {SpaceRegistry, "Stash-25"}}, "www.test.com")
  #     assert IntervalStash.get({:via, Registry, {SpaceRegistry, "Stash-25"}}) == "www.test.com"
  #   end
  # end

  # describe "test check_room_status from space_channel" do
  #   test "successful lookup of a server" do
  #     assert Registry.lookup(SpaceRegistry, "space_server:25") == [{#PID<0.532.0>, nil}]
  #   end

  #   # test "stash already running" do
  #   #   # {:error, {:already_started, #PID<0.530.0>}}
  #   # end
  # end
end
