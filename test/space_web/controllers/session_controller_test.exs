defmodule Space.SessionControllerTest do
  use SpaceWeb.ConnCase

  alias SpaceWeb.SessionController

  @create_attrs %{"name" => "james"}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "display username form", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :index))
      assert html_response(conn, 200) =~ "Welcome!"
    end
  end

  describe "create user" do
    test "redirects to chat index when data is valid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), %{"chat_name_form" => @create_attrs})
      assert redirected_to(conn) == Routes.page_path(conn, :index)

      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Current Interval:"
    end
  end

  describe "View chat page with invalid session data" do
    test "redirects to chat index when data is valid", %{conn: conn} do
      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 302)
      assert conn.halted
    end
  end
end
