defmodule UploadexTest do
  use ExUnit.Case
  doctest Uploadex

  alias Uploadex.{
    Files,
    TestStorage,
  }

  describe "Files" do
    setup do
      Uploadex.TestStorage.start_link()
      :ok
    end

    test "store_files/1" do
      user = %User{}
      assert {:ok, %{}} = Files.store_files(user)
      assert Uploadex.TestStorage.get_stored == user.files
    end

    test "delete_files/1" do
      assert {:ok, %{}} = Files.delete_files(%User{})
      assert TestStorage.get_deleted == TestUploader.get_files(%User{})
    end

    test "delete_previous_files/1 with no changed files" do
      assert {:ok, %{}} = Files.delete_previous_files(%User{}, %User{})
      assert TestStorage.get_deleted == []
    end

    test "delete_previous_files/1 with changed files" do
      assert {:ok, %{}} = Files.delete_previous_files(%User{files: [%{filename: "2"}]}, %User{})
      assert TestStorage.get_deleted == [%{filename: "1"}]
    end

    test "get_file_url/1 when record only has one file" do
      user = %User{files: [%{filename: "file"}]}
      assert "file" == Files.get_file_url(user)
    end

    test "get_file_url/1 when record only has many files" do
      assert {:error, "This record has more than one file."} == Files.get_file_url(%User{})
    end

    test "get_file_url/1 when record has no files" do
      assert nil == Files.get_file_url(%User{files: []})
    end

    test "get_file_url/2" do
      %{files: [file1, _file2]} = user = %User{}
      assert file1.filename == Files.get_file_url(user, file1)
    end

    test "get_files_url/1" do
      user = %User{}
      assert Enum.map(user.files, & &1.filename) == Files.get_files_url(user)
    end

    test "get_files_url/2" do
      %{files: [file1, _file2]} = user = %User{}
      assert [file1.filename] == Files.get_files_url(user, file1)
    end
  end
end
