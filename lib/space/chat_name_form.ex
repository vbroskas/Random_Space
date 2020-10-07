defmodule Space.ChatNameForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
  end

  @allowed_fields ~w(name)a
  @required_fields @allowed_fields

  def new_changeset(chat_name_form, params \\ %{}) do
    chat_name_form
    |> cast(params, @allowed_fields)
  end

  def validate_changeset(chat_name_form, params) do
    new_changeset(chat_name_form, params)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 2)
    |> put_change(:id, Ecto.UUID.generate())
  end
end
