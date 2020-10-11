defmodule SpaceWeb.PageControllerTest do
  use SpaceWeb.ConnCase
  alias Space.ChatNameForm
  import Ecto.Changeset

  setup do
    # setup code
    :ok
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert html_response(conn, 200) =~
             "Spaced Out is an anonymous chat interface to view random images from space and discuss them with strangers"
  end

  describe "index" do
    test "", %{conn: conn} do
      changeset = ChatNameForm.new_changeset(%ChatNameForm{})
      conn = get(conn, Routes.page_path(conn, :index, changeset: changeset))

      assert html_response(conn, 200) =~
               "Spaced Out is an anonymous chat interface to view random images from space and discuss them with strangers"
    end
  end
end
