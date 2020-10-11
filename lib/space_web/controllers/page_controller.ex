defmodule SpaceWeb.PageController do
  use SpaceWeb, :controller

  plug :authenticate when action in [:index]

  def index(conn, _params) do
    render(conn, "index.html")
  end

  defp authenticate(conn, _opts) do
    case get_session(conn, :user_id) do
      nil ->
        IO.puts("No Key in session!!!")

        conn
        |> put_flash(:error, "Must create a username to chat!")
        |> redirect(to: Routes.session_path(conn, :index))
        |> halt()

      _ ->
        IO.puts("Session Valid!")
        conn
    end
  end
end
