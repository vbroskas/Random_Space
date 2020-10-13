defmodule SpaceWeb.SpaceChannelTest do
  use SpaceWeb.ChannelCase
  import ExUnit.CaptureLog
  alias SpaceWeb.UserSocket
  alias SpaceWeb.SpaceChannel

  setup do
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
end
