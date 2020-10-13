defmodule SpaceWeb.SpaceChannelTest do
  use SpaceWeb.ChannelCase
  import ExUnit.CaptureLog
  alias SpaceWeb.UserSocket
  alias SpaceWeb.SpaceChannel
  alias Space.IntervalServer
  alias Space.IntervalStash

  setup do
    # connecting to the socket and interval channel will also run through the process of starting a stash and
    # genserver process for the specified interval
    {:ok, _, socket} =
      UserSocket
      |> socket("user_id", %{user_id: "123asdf", username: "james"})
      |> subscribe_and_join(SpaceChannel, "space:25")

    %{socket: socket}
  end

  test "new msg from clinet", %{socket: socket} do
    push(socket, "new_msg", %{body: "The mesage"})

    assert_broadcast "new_msg", %{
      body: "The mesage",
      username: "james",
      user_id: "123asdf"
    }
  end

  describe "check that stash update and get works" do
    test "check stash insert" do
      IntervalStash.update({:via, Registry, {SpaceRegistry, "Stash-25"}}, "www.test.com")
      assert IntervalStash.get({:via, Registry, {SpaceRegistry, "Stash-25"}}) == "www.test.com"
    end
  end

  describe "test calls and casts in genserver" do
    test "check room status cast" do
      assert IntervalServer.check_room_status(25) == :ok
    end
  end
end
