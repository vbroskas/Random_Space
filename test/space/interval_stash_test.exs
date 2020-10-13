defmodule Space.IntervalStashTest do
  alias Space.IntervalStash

  setup do
    {:ok, _pid} = IntervalStash.start_link(25)
    :ok
  end
end
