defmodule UploadexTest do
  use ExUnit.Case
  doctest Uploadex

  alias Uploadex.{
    Files,
    TestStorage,
  }

  setup do
    Uploadex.TestStorage.start_link()
    :ok
  end

  describe "store_files/1" do
    test "stores all files from the record" do
      user = %User{}
      assert {:ok, %{}} = Files.store_files(user)
      assert user.files == Uploadex.TestStorage.get_stored()
    end
  end

  describe "delete_files/1" do
    test "delete all files from the record" do
      user = %User{}
      assert {:ok, %{}} = Files.delete_files(user)
      assert user.files == Uploadex.TestStorage.get_deleted()
    end
  end

  describe "delete_previous_files/1" do
    test "with no changed files" do
      assert {:ok, %{}} = Files.delete_previous_files(%User{}, %User{})
      assert [] == TestStorage.get_deleted()
    end

    test "with changed files" do
      assert {:ok, %{}} = Files.delete_previous_files(%User{files: [%{filename: "2"}]}, %User{})
      assert [%{filename: "1"}] == TestStorage.get_deleted()
    end
  end

  describe "get_file_url" do
    test "when record only has one file" do
      user = %User{files: [%{filename: "file"}]}
      assert "file" == Files.get_file_url(user)
    end

    test "when record only has many files" do
      assert {:error, "This record has more than one file."} == Files.get_file_url(%User{})
    end

    test "when record has no files" do
      assert nil == Files.get_file_url(%User{files: []})
    end

    test "selecting the files" do
      %{files: [file1, _file2]} = user = %User{}
      assert file1.filename == Files.get_file_url(user, file1)
    end
  end

  describe "get_files_url" do
    test "returns all files in a list" do
      user = %User{}
      assert Enum.map(user.files, & &1.filename) == Files.get_files_url(user)
    end

    test "returns the selected files in a list" do
      %{files: [file1, _file2]} = user = %User{}
      assert [file1.filename] == Files.get_files_url(user, file1)
    end
  end

  describe "Storage opts" do
    test "is passed to the storage considering default opts" do
      user = %User{files: [%{filename: "file"}]}
      default_opts = TestUploader.default_opts(TestStorage)
      {TestStorage, custom_opts} = TestUploader.storage(user)

      {:ok, _} = Files.store_files(user)
      assert Keyword.merge(default_opts, custom_opts) == TestStorage.get_opts()
    end
  end
end
