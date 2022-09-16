defmodule Uploadex.Testing do
  @moduledoc """
  This module simplifies testing and assertions involving `Uploadex`.

  ## Usage in Tests

  The most convenient way to use `Uploadex.Testing` is to `use` the module:

      use Uploadex.Testing

  That will define all the helper functions you'll need to make assertions.

  ## Some examples of how to use the functions

  ```elixir
  # Asserting that 2 files were stored
  assert_stored_files_count(2)

  # Asserting the filenames of the stored files
  assert_stored_files(["file1.pdf", "file2.pdf"])

  # Asserting the filenames of the stored files ignoring the order
  assert_stored_files(["file2.pdf", "file1.pdf"], ignore_order: true)

  # Asserting that no file was stored
  refute_stored_files()

  # Asserting that 1 files was deleted
  assert_deleted_files_count(1)

  # Asserting the filenames of the deleted files
  assert_deleted(["file3.pdf"])

  # Asserting the filenames of the deleted files ignoring the order
  assert_deleted_files(["file2.pdf", "file1.pdf"], ignore_order: true)

  # Asserting that no file was deleted
  refute_deleted_files()
  ```

  If you need a more low level API, you can directly use the `Uploadex.TestStorage` functions.
  """

  import ExUnit.Assertions, only: [assert: 2]

  alias Uploadex.TestStorage

  @doc """
  Imports all functions from `Uploadex.Testing`
  and defines a setup callback to start the `Uploadex.TestStorage`.
  """
  defmacro __using__(_opts) do
    quote do
      import Uploadex.Testing

      setup :start_test_storage
    end
  end

  @doc """
  Starts the `Uploadex.TestStorage`.

  After importing it, you can use as a `ExUnit` setup callback:

      import Uploadex.Testing

      setup :start_test_storage

  """
  @spec start_test_storage(context :: map()) :: :ok
  def start_test_storage(_ctx \\ %{}) do
    TestStorage.start_link()
    :ok
  end

  @doc """
  Asserts that the given `expected_count` number of files was stored.
  """
  @spec assert_stored_files_count(expected_count :: integer) :: true
  def assert_stored_files_count(expected_count) when is_integer(expected_count) do
    stored_files = TestStorage.get_stored()
    stored_count = Enum.count(stored_files)

    error_message = """
    Expected #{expected_count} files stored.

    Got #{stored_count} instead:

    #{inspect(stored_files)}
    """

    assert expected_count == stored_count, error_message
  end

  @doc """
  Asserts that the given `expected_count` number of files was deleted.
  """
  @spec assert_deleted_files_count(expected_count :: integer) :: true
  def assert_deleted_files_count(expected_count) when is_integer(expected_count) do
    deleted_files = TestStorage.get_deleted()
    deleted_count = Enum.count(deleted_files)

    error_message = """
    Expected #{expected_count} files deleted.

    Got #{deleted_count} instead:

    #{inspect(deleted_files)}
    """

    assert expected_count == deleted_count, error_message
  end

  @doc """
  Asserts that no file was stored.
  """
  @spec refute_stored_files() :: true
  def refute_stored_files() do
    assert_stored_files_count(0)
  end

  @doc """
  Asserts that no file was deleted.
  """
  @spec refute_deleted_files() :: true
  def refute_deleted_files() do
    assert_deleted_files_count(0)
  end

  @doc """
  Asserts that all the files in `expected_files` were stored
  in the exact order that they are passed in the list.

  ## Options

    * `ignoring_order`: if `true`, ignores the order of the files when asserting (defaults to `false`)

  """
  @spec assert_stored_files(expected_files :: list(), opts :: [ignoring_order: boolean()]) :: true
  def assert_stored_files(expected_files, opts \\ []) do
    ignore_order? = opts[:ignoring_order] || false
    stored_files = TestStorage.get_stored()

    error_message = """
    Expected the files

    #{inspect(expected_files)}

    to be stored. Instead got:

    #{inspect(stored_files)}
    """

    if ignore_order? do
      assert Enum.sort(expected_files) == Enum.sort(stored_files), error_message
    else
      assert expected_files == stored_files, error_message
    end
  end

  @doc """
  Asserts that all the files in `expected_files` were deleted
  in the exact order that they are passed in the list.

  ## Options

    * `ignoring_order`: if `true`, ignores the order of the files when asserting (defaults to `false`)

  """
  @spec assert_deleted_files(expected_files :: list(), opts :: [ignoring_order: boolean()]) ::
          true
  def assert_deleted_files(expected_files, opts \\ []) do
    ignore_order? = opts[:ignoring_order] || false
    deleted_files = TestStorage.get_deleted()

    error_message = """
    Expected the files

    #{inspect(expected_files)}

    to be deleted. Instead got:

    #{inspect(deleted_files)}
    """

    if ignore_order? do
      assert Enum.sort(expected_files) == Enum.sort(deleted_files), error_message
    else
      assert expected_files == deleted_files, error_message
    end
  end
end
