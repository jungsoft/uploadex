defmodule Uploadex.Files do
  @moduledoc """
  Functions to store and delete files.
  """

  @type record :: any()

  alias Uploadex.Validation

  defp uploader!, do: Application.fetch_env!(:uploadex, :uploader)

  @doc """
  Stores all files of a record, as defined by the uploader.

  Files that are not maps are ignored, which allows for assigning an existing file to a record without recreating it, by simply passing it's filename.
  """
  @spec store_files(record) :: {:ok, record} | {:error, any()}
  def store_files(record) do
    storage_opts = get_storage_opts(record)
    files = wrap_files(record)
    extensions = get_accepted_extensions(record)

    case Validation.validate_extensions(files, extensions) do
      :ok ->
        files
        |> Enum.filter(&is_map/1)
        |> do_store_files(record, storage_opts)

      error ->
        error
    end
  end

  # Recursively stores all files, stopping if one operation fails.
  defp do_store_files([file | remaining_files], record, {storage, opts}) do
    case apply(storage, :store, [file, opts]) do
      :ok -> do_store_files(remaining_files, record, {storage, opts})
      {:error, error} -> {:error, error}
    end
  end

  defp do_store_files([], record, _storage_opts) do
    {:ok, record}
  end

  @doc """
  Deletes all files that changed.
  """
  @spec delete_previous_files(record, record) :: {:ok, record} | {:error, any()}
  def delete_previous_files(new_record, previous_record) do
    storage_opts = get_storage_opts(new_record)

    new_files = wrap_files(new_record)
    old_files = wrap_files(previous_record)

    new_files
    |> get_changed_files(old_files)
    |> do_delete_files(new_record, storage_opts)
  end

  @doc """
  Deletes all files for a record.
  """
  @spec delete_files(record) :: {:ok, record} | {:error, any()}
  def delete_files(record) do
    storage_opts = get_storage_opts(record)

    record
    |> wrap_files()
    |> do_delete_files(record, storage_opts)
  end

  defp do_delete_files(files, record, {storage, opts}) do
    Enum.each(files, fn file -> apply(storage, :delete, [file, opts]) end)
    {:ok, record}
  end

  # Returns all old files that are not in new files.
  defp get_changed_files(new_files, old_files) do
    old_files -- new_files
  end

  @spec get_file_url(record) :: String.t | nil | {:error, String.t}
  def get_file_url(record) do
    record
    |> get_files_url()
    |> case do
      [file] -> file
      [] -> nil
      _ -> {:error, "This record has more than one file."}
    end
  end

  @spec get_file_url(record, String.t) :: String.t | nil | {:error, String.t}
  def get_file_url(record, file) do
    record
    |> get_files_url(file)
    |> List.first()
  end

  @spec get_files_url(record) :: [String.t]
  def get_files_url(record) do
    get_files_url(record, wrap_files(record))
  end

  @spec get_files_url(record, String.t | [String.t]) :: [String.t]
  def get_files_url(record, files) do
    {storage, opts} = get_storage_opts(record)

    files
    |> List.wrap()
    |> Enum.map(fn file -> apply(storage, :get_url, [file, opts]) end)
  end

  @spec get_temporary_file(record, String.t) :: String.t | nil | {:error, String.t}
  def get_temporary_file(record, path) do
    record
    |> get_temporary_files(path)
    |> case do
      [file] -> file
      [] -> nil
      _ -> {:error, "This record has more than one file."}
    end
  end

  @spec get_temporary_file(record, String.t, String.t) :: String.t | nil | {:error, String.t}
  def get_temporary_file(record, file, path) do
    record
    |> get_temporary_files(file, path)
    |> List.first()
  end

  @spec get_temporary_files(record, String.t) :: [String.t]
  def get_temporary_files(record, path) do
    get_temporary_files(record, wrap_files(record), path)
  end

  @spec get_temporary_files(record, String.t | [String.t], String.t) :: [String.t]
  def get_temporary_files(record, files, path) do
    {storage, opts} = get_storage_opts(record)

    files
    |> List.wrap()
    |> Enum.map(fn file -> apply(storage, :get_temporary_file, [file, path, opts]) end)
  end

  # Get storage opts considering default values
  defp get_storage_opts(record) do
    {storage, opts} = uploader!().storage(record)
    default_opts = uploader!().default_opts(storage)

    {storage, Keyword.merge(default_opts, opts)}
  end

  # Wraps the user defined `get_files` function to always return a list
  defp wrap_files(record) do
    uploader = uploader!()

    record
    |> uploader.get_files()
    |> List.wrap()
    |> Enum.reject(&is_nil/1)
  end

  defp get_accepted_extensions(record) do
    case function_exported?(uploader!(), :accepted_extensions, 1) do
      true -> uploader!().accepted_extensions(record)
      false -> :any
    end
  end
end
