defmodule SpaceWeb.SessionController do
  use SpaceWeb, :controller
  import Ecto.Changeset
  alias Space.{ChatNameForm}

  @doc """
  display name creation template/form
  """
  def index(conn, _params) do
    changeset = ChatNameForm.new_changeset(%ChatNameForm{})
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"chat_name_form" => form_input}) do
    changeset = ChatNameForm.validate_changeset(%ChatNameForm{}, form_input)

    case apply_action(changeset, :insert) do
      {:ok, %{id: user_id, name: username} = _data} ->
        auth_token = generate_auth_token(conn, user_id)

        conn
        |> put_session(:user_id, user_id)
        |> put_session(:username, username)
        |> put_session(:auth_token, auth_token)
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset} ->
        render(conn, "index.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: Routes.session_path(conn, :index))
  end

  defp generate_auth_token(conn, user_id) do
    Phoenix.Token.sign(conn, "salt identifier", user_id)
  end
end
