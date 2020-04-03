defmodule ContextTest do
  use ExUnit.Case

  alias Uploadex.{
    TestStorage,
  }

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(Uploadex.Repo)
    TestStorage.start_link()
    :ok
  end

  @upload %{filename: "1.jpg", path: "path", content_type: "jpg"}
  @uploads [@upload]

  test "create_with_file/3" do
    {:ok, %UserSchema{files: files}} =
      %UserSchema{}
      |> UserSchema.changeset(%{files: @uploads})
      |> TestUploader.create_with_file()

    [stored_file] = TestStorage.get_stored()
    assert stored_file.content_type == @upload.content_type
    assert stored_file.path == @upload.path
    assert stored_file.filename != @upload.filename

    assert files == TestStorage.get_stored()
  end
end
