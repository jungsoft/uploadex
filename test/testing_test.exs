defmodule Uploadex.TestingTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use Uploadex.Testing

  alias Uploadex.TestStorage

  describe "assert_stored_files_count/1" do
    test "asserts the stored files count matches the given parameter" do
      store_files(["file1.jpg"])
      assert_stored_files_count(1)
      assert 1 == Enum.count(TestStorage.get_stored())

      store_files(["file2.jpg", "file3.jpg"])
      assert_stored_files_count(3)
      assert 3 == Enum.count(TestStorage.get_stored())
    end

    test "prints a helpful message when assertion fails" do
      store_files(["file1.jpg"])

      try do
        assert_stored_files_count(99)
        flunk("assert should have failed but did not")
      rescue
        error in [ExUnit.AssertionError] ->
          expected = """
          Expected 99 files stored.

          Got 1 instead:

          [%{filename: "file1.jpg"}]
          """

          assert error.message == expected
      end
    end
  end

  describe "assert_deleted_files_count/1" do
    test "asserts the deleted files count matches the given parameter" do
      delete_files(["file1.jpg"])
      assert_deleted_files_count(1)
      assert 1 == Enum.count(TestStorage.get_deleted())

      delete_files(["file2.jpg", "file3.jpg"])
      assert_deleted_files_count(3)
      assert 3 == Enum.count(TestStorage.get_deleted())
    end

    test "prints a helpful message when assertion fails" do
      delete_files(["file1.jpg"])

      try do
        assert_deleted_files_count(99)
        flunk("assert should have failed but did not")
      rescue
        error in [ExUnit.AssertionError] ->
          expected = """
          Expected 99 files deleted.

          Got 1 instead:

          [%{filename: "file1.jpg"}]
          """

          assert error.message == expected
      end
    end
  end

  describe "refute_stored_files/0" do
    test "asserts that no file was stored" do
      store_files([])
      refute_stored_files()
      assert 0 == Enum.count(TestStorage.get_stored())
    end

    test "prints a helpful message when assertion fails" do
      store_files(["file1.jpg"])

      try do
        refute_stored_files()
        flunk("assert should have failed but did not")
      rescue
        error in [ExUnit.AssertionError] ->
          expected = """
          Expected no files stored.

          Got: [%{filename: "file1.jpg"}]
          """

          assert error.message == expected
      end
    end
  end

  describe "refute_deleted_files/0" do
    test "asserts that no file was deleted" do
      delete_files([])
      refute_deleted_files()
      assert 0 == Enum.count(TestStorage.get_deleted())
    end

    test "prints a helpful message when assertion fails" do
      delete_files(["file1.jpg"])

      try do
        refute_deleted_files()
        flunk("assert should have failed but did not")
      rescue
        error in [ExUnit.AssertionError] ->
          expected = """
          Expected no files deleted.

          Got: [%{filename: "file1.jpg"}]
          """

          assert error.message == expected
      end
    end
  end

  describe "assert_stored_files/2" do
    test "asserts the stored files is exactly equal to the given parameter" do
      store_files(["file1.jpg", "file2.jpg"])
      assert_stored_files([%{filename: "file1.jpg"}, %{filename: "file2.jpg"}])
      assert [%{filename: "file1.jpg"}, %{filename: "file2.jpg"}] == TestStorage.get_stored()

      store_files(["file3.jpg"])

      assert_stored_files([
        %{filename: "file1.jpg"},
        %{filename: "file2.jpg"},
        %{filename: "file3.jpg"}
      ])

      assert [%{filename: "file1.jpg"}, %{filename: "file2.jpg"}, %{filename: "file3.jpg"}] ==
               TestStorage.get_stored()
    end

    test "with 'ignoring_order: true' asserts the stored files are the same as the given parameter ignoring the order" do
      store_files(["file1.jpg", "file2.jpg"])

      assert_stored_files([%{filename: "file2.jpg"}, %{filename: "file1.jpg"}],
        ignoring_order: true
      )

      assert [%{filename: "file1.jpg"}, %{filename: "file2.jpg"}] == TestStorage.get_stored()

      store_files(["file3.jpg"])

      assert_stored_files(
        [%{filename: "file3.jpg"}, %{filename: "file1.jpg"}, %{filename: "file2.jpg"}],
        ignoring_order: true
      )

      assert [%{filename: "file1.jpg"}, %{filename: "file2.jpg"}, %{filename: "file3.jpg"}] ==
               TestStorage.get_stored()
    end

    test "prints a helpful message when assertion fails" do
      store_files(["file1.jpg"])

      try do
        assert_stored_files([%{filename: "wrong-file-name.jpg"}])
        flunk("assert should have failed but did not")
      rescue
        error in [ExUnit.AssertionError] ->
          expected = """
          Expected the files

          [%{filename: "wrong-file-name.jpg"}]

          to be stored. Instead got:

          [%{filename: "file1.jpg"}]
          """

          assert error.message == expected
      end
    end
  end

  describe "assert_deleted_files/2" do
    test "asserts the deleted files is exactly equal to the given parameter" do
      delete_files(["file1.jpg", "file2.jpg"])
      assert_deleted_files([%{filename: "file1.jpg"}, %{filename: "file2.jpg"}])
      assert [%{filename: "file1.jpg"}, %{filename: "file2.jpg"}] == TestStorage.get_deleted()

      delete_files(["file3.jpg"])

      assert_deleted_files([
        %{filename: "file1.jpg"},
        %{filename: "file2.jpg"},
        %{filename: "file3.jpg"}
      ])

      assert [%{filename: "file1.jpg"}, %{filename: "file2.jpg"}, %{filename: "file3.jpg"}] ==
               TestStorage.get_deleted()
    end

    test "with 'ignoring_order: true' asserts the deleted files are the same as the given parameter ignoring the order" do
      delete_files(["file1.jpg", "file2.jpg"])

      assert_deleted_files([%{filename: "file2.jpg"}, %{filename: "file1.jpg"}],
        ignoring_order: true
      )

      assert [%{filename: "file1.jpg"}, %{filename: "file2.jpg"}] == TestStorage.get_deleted()

      delete_files(["file3.jpg"])

      assert_deleted_files(
        [%{filename: "file3.jpg"}, %{filename: "file1.jpg"}, %{filename: "file2.jpg"}],
        ignoring_order: true
      )

      assert [%{filename: "file1.jpg"}, %{filename: "file2.jpg"}, %{filename: "file3.jpg"}] ==
               TestStorage.get_deleted()
    end

    test "prints a helpful message when assertion fails" do
      delete_files(["file1.jpg"])

      try do
        assert_deleted_files([%{filename: "wrong-file-name.jpg"}])
        flunk("assert should have failed but did not")
      rescue
        error in [ExUnit.AssertionError] ->
          expected = """
          Expected the files

          [%{filename: "wrong-file-name.jpg"}]

          to be deleted. Instead got:

          [%{filename: "file1.jpg"}]
          """

          assert error.message == expected
      end
    end
  end

  defp store_files(filenames) do
    files = Enum.map(filenames, fn filename -> %{filename: filename} end)
    {:ok, _} = TestUploader.store_files(%User{files: files})
  end

  defp delete_files(filenames) do
    files = Enum.map(filenames, fn filename -> %{filename: filename} end)
    {:ok, _} = TestUploader.delete_files(%User{files: files})
  end
end
