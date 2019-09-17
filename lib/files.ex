defmodule Uploadex.Files do
  @moduledoc """
  Functions to store and delete files.
  This is an abstraction on top of the [Arc.Actions.Store](https://github.com/stavro/arc/blob/master/lib/arc/actions/store.ex) and [Arc.Actions.Delete](https://github.com/stavro/arc/blob/master/lib/arc/actions/delete.ex), dealing with all files of a given record.
  """

  defp uploader!, do: Application.fetch_env!(:uploadex, :uploader)

  @doc """
  Wraps the user defined `get_files` function to always return a list
  """
  def wrap_files(record) do
    uploader = uploader!()

    record
    |> uploader.get_files()
    |> List.wrap()
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Stores all files of a record, as defined by the uploader.
  Used in insert functions.

  Since uploader.store only accepts maps, files that are not in that format are ignored.
  This allows for assigning an existing file to a record without recreating it, by simply passing it's filename.
  """
  def store_files(record) do
    storage_opts = get_storage_opts(record)

    record
    |> wrap_files()
    |> Enum.filter(&is_map/1)
    |> do_store_files(record, storage_opts)
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
  Used in update functions.
  """
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
  Used in delete functions.
  """
  def delete_files(record) do
    storage_opts = get_storage_opts(record)

    record
    |> wrap_files()
    |> do_delete_files(record, storage_opts)
  end

  defp do_delete_files([file | remaining_files], record, {storage, opts}) do
    case apply(storage, :delete, [file, opts]) do
      :ok -> do_delete_files(remaining_files, record, {storage, opts})
      {:error, error} -> {:error, error}
    end
  end

  defp do_delete_files([], record, _storage_opts) do
    {:ok, record}
  end

  # Returns all old files that are not in new files.
  defp get_changed_files(new_files, old_files) do
    old_files -- new_files
  end

  def get_file_url(record) do
    record
    |> get_files_url()
    |> case do
      [file] -> file
      [] -> nil
      _ -> {:error, "This record has more than one file."}
    end
  end

  def get_file_url(record, file) do
    record
    |> get_files_url(file)
    |> List.first()
  end

  def get_files_url(record) do
    get_files_url(record, wrap_files(record))
  end

  def get_files_url(record, files) do
    {storage, opts} = get_storage_opts(record)

    files
    |> List.wrap()
    |> Enum.map(fn file -> apply(storage, :get_url, [file, opts]) end)
  end

  # Get storage opts considering default values
  defp get_storage_opts(record) do
    {storage, opts} = uploader!().storage(record)
    default_opts = uploader!().default_opts(storage)

    {storage, Keyword.merge(default_opts, opts)}
  end
end
