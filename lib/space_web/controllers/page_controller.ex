defmodule SpaceWeb.PageController do
  use SpaceWeb, :controller
  import Ecto.Changeset
  alias Space.{ChatNameForm}

  def index(conn, _params) do
    changeset = ChatNameForm.new_changeset(%ChatNameForm{})
    render(conn, "index.html", changeset: changeset)
  end

  def space_chat(
        conn,
        %{"chat_name_form" => %{"name" => _username} = form_input} = _params
      ) do
    changeset = ChatNameForm.validate_changeset(%ChatNameForm{}, form_input)

    case apply_action(changeset, :insert) do
      {:ok, %{id: user_id, name: username} = _data} ->
        auth_token = generate_auth_token(conn, user_id)

        conn
        |> assign(:auth_token, auth_token)
        |> assign(:user_id, user_id)
        |> assign(:username, username)
        |> put_session(:user_id, user_id)
        |> put_session(:username, username)
        |> put_session(:auth_token, auth_token)
        |> render("space_chat.html")

      {:error, changeset} ->
        IO.puts("NOT VALID")
        render(conn, "index.html", changeset: changeset)
    end
  end

  defp generate_auth_token(conn, user_id) do
    Phoenix.Token.sign(conn, "salt identifier", user_id)
  end
end
