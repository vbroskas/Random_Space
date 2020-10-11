defmodule ChatNameFormTest do
  use ExUnit.Case, async: true
  alias Space.ChatNameForm

  describe "new changeset" do
    setup do
      :ok
    end

    test "validate changeset" do
      changeset = ChatNameForm.validate_changeset(%ChatNameForm{}, %{"name" => "james"})
      assert changeset.valid? == true
    end

    test "validate changeset is invalid" do
      changeset = ChatNameForm.validate_changeset(%ChatNameForm{}, %{"name" => ""})
      assert changeset.valid? == false
    end

    test "validate changeset is invalid name too short" do
      changeset = ChatNameForm.validate_changeset(%ChatNameForm{}, %{"name" => "x"})
      assert changeset.valid? == false
    end

    test "validate changeset is invalid name too long" do
      changeset =
        ChatNameForm.validate_changeset(%ChatNameForm{}, %{
          "name" => "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        })

      assert changeset.valid? == false
    end
  end
end
