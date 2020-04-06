defmodule ContextTest do
  use ExUnit.Case

  alias Ecto.Adapters.SQL.Sandbox
  alias Uploadex.{
    Repo,
    TestStorage,
  }

  @upload %{filename: "1.jpg", path: "path", content_type: "jpg"}
  @upload2 %{filename: "2.jpg", path: "path2", content_type: "png"}
  @uploads [@upload]

  setup do
    Sandbox.checkout(Repo)
    TestStorage.start_link()

    {:ok, user} = %UserSchema{} |> UserSchema.changeset(%{files: @uploads}) |> TestUploader.create_with_file()
    TestStorage.clear_stored()
    %{user: user}
  end

  test "create_with_file/2" do
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

  test "update_with_file/3 stores new files and delete previous", %{user: user} do
    initial_files = user.files

    {:ok, %UserSchema{files: files}} =
      user
      |> UserSchema.changeset(%{files: [@upload2]})
      |> TestUploader.update_with_file(user)

    [stored_file] = TestStorage.get_stored()
    assert stored_file.content_type == @upload2.content_type
    assert stored_file.path == @upload2.path
    assert stored_file.filename != @upload2.filename

    assert files == TestStorage.get_stored()
    assert initial_files == TestStorage.get_deleted()
  end

  test "update_with_file_keep_previous/2 stores new files and keeps previous", %{user: user} do
    {:ok, %UserSchema{files: files}} =
      user
      |> UserSchema.changeset(%{files: [@upload2]})
      |> TestUploader.update_with_file_keep_previous()

    [stored_file] = TestStorage.get_stored()
    assert stored_file.content_type == @upload2.content_type
    assert stored_file.path == @upload2.path
    assert stored_file.filename != @upload2.filename

    assert files == TestStorage.get_stored()
    assert [] == TestStorage.get_deleted()
  end

  test "delete_with_file/2 deletes record and files", %{user: user} do
    {:ok, %UserSchema{files: files}} = TestUploader.delete_with_file(user)

    assert [] == TestStorage.get_stored()
    assert files == TestStorage.get_deleted()
    assert nil == Repo.get(UserSchema, user.id)
  end
end
