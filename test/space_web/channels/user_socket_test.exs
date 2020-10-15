defmodule SpaceWeb.UserSocketTest do
  use SpaceWeb.ChannelCase
  alias SpaceWeb.UserSocket
  import ExUnit.CaptureLog

  describe "connect/3 success" do
    test "can be connected to with a valid token" do
      assert {:ok, %Phoenix.Socket{}} =
               connect(UserSocket, %{"token" => generate_token(1), "username" => "sam"})

      assert {:ok, %Phoenix.Socket{}} =
               connect(UserSocket, %{"token" => generate_token(2), "username" => "bob"})
    end
  end

  describe "connect/3 error" do
    test "cannot be connected to with an invalid salt" do
      params = %{"token" => generate_token(1, salt: "invalid"), "username" => "bob"}

      assert capture_log(fn ->
               assert :error = connect(UserSocket, params)
             end) =~ "[error] #{UserSocket} connect error :invalid"
    end

    test "cannot be connected to without a token" do
      params = %{"username" => "bob"}

      assert capture_log(fn ->
               assert :error = connect(UserSocket, params)
             end) =~ "[error] #{UserSocket} connect error missing params"
    end

    test "cannot be connected to with a nonsense token" do
      params = %{"token" => "nonsense", "username" => "bob"}

      assert capture_log(fn ->
               assert :error = connect(UserSocket, params)
             end) =~ "[error] #{UserSocket} connect error :invalid"
    end

    test "cannot be connected to without username" do
      params = %{"token" => generate_token(2)}

      assert capture_log(fn ->
               assert :error = connect(UserSocket, params)
             end) =~ "[error] #{UserSocket} connect error missing params"
    end
  end

  describe "id/1" do
    test "an identifier is based on the connected ID" do
      assert {:ok, socket} =
               connect(UserSocket, %{"token" => generate_token(1), "username" => "bob"})

      assert UserSocket.id(socket) == "auth_socket:1"

      assert {:ok, socket} =
               connect(UserSocket, %{"token" => generate_token(2), "username" => "bob"})

      assert UserSocket.id(socket) == "auth_socket:2"
    end
  end

  defp generate_token(id, opts \\ []) do
    salt = Keyword.get(opts, :salt, "salt identifier")
    Phoenix.Token.sign(SpaceWeb.Endpoint, salt, id)
  end
end
