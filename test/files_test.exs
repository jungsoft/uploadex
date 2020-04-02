defmodule UploadexTest do
  use ExUnit.Case
  doctest Uploadex

  alias Uploadex.{
    TestStorage,
    UploadexUse,
  }

  setup do
    Uploadex.TestStorage.start_link()
    :ok
  end

  defmodule UploadexFiles do
    use UploadexUse

    @impl true
    def get_fields(%User{}), do: :files

    @impl true
    def default_opts(Uploadex.TestStorage), do: [a: 1, b: 2]

    @impl true
    def storage(%User{}, _field) do
      {Uploadex.TestStorage, [directory: "/test/dir/"]}
    end

    @impl true
    def accepted_extensions(%User{}, _field), do: ~w(.jpg .png)
  end

  describe "store_files/1" do
    test "stores all files from the record" do
      user = %User{}
      assert {:ok, %{}} = UploadexFiles.store_files(user)
      assert user.files == Uploadex.TestStorage.get_stored()
    end

    test "fails when extension is not accepted" do
      user = %User{files: [%{filename: "file.pdf"}]}
      assert {:error, "Some files in [\"file.pdf\"] violate the accepted extensions: [\".jpg\", \".png\"]"} = UploadexFiles.store_files(user)
    end
  end

  describe "delete_files/1" do
    test "delete all files from the record" do
      user = %User{}
      assert {:ok, %{}} = UploadexFiles.delete_files(user)
      assert user.files == Uploadex.TestStorage.get_deleted()
    end
  end

  describe "delete_previous_files/1" do
    test "with no changed files" do
      assert {:ok, %{}} = UploadexFiles.delete_previous_files(%User{}, %User{})
      assert [] == TestStorage.get_deleted()
    end

    test "with changed files" do
      assert {:ok, %{}} = UploadexFiles.delete_previous_files(%User{files: [%{filename: "2.jpg"}, "3.jpg"]}, %User{})
      assert [%{filename: "1.jpg"}] == TestStorage.get_deleted()
    end
  end

  describe "get_file_url" do
    test "selecting the files" do
      %{files: [file1, _file2]} = user = %User{}
      assert {:ok, file1.filename} == UploadexFiles.get_file_url(user, file1, :files)
    end
  end

  describe "get_files_url" do
    test "returns all files in a list" do
      user = %User{}
      assert {:ok, Enum.map(user.files, & &1.filename)} == UploadexFiles.get_files_url(user, :files)
    end

    test "returns the selected files in a list" do
      %{files: [file1, _file2]} = user = %User{}
      assert {:ok, [file1.filename]} == UploadexFiles.get_files_url(user, file1, :files)
    end
  end

  describe "Storage opts" do
    test "is passed to the storage considering default opts" do
      user = %User{files: [%{filename: "file.png"}]}
      default_opts = TestUploader.default_opts(TestStorage)
      {TestStorage, custom_opts} = TestUploader.storage(user, :files)

      {:ok, _} = UploadexFiles.store_files(user)
      assert Keyword.merge(default_opts, custom_opts) == TestStorage.get_opts()
    end
  end
end
