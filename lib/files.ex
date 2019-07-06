defmodule Uploadex.Files do
  @moduledoc """
  Functions to store and delete files
  """

  @doc """
  Stores all files in a record.
  """
  def store_files(record, uploader) do
    record
    |> uploader.do_get_files()
    |> do_store_files(record, uploader)
  end

  defp do_store_files([file | remaining_files], record, uploader) do
    case uploader.store({file, record}) do
      {:ok, _file} -> do_store_files(remaining_files, record, uploader)
      {:error, error} -> {:error, error}
    end
  end

  defp do_store_files([], record, _uploader) do
    {:ok, record}
  end

  @doc """
  Deletes all files that changed. Used in update functions.
  """
  def delete_previous_files(new_record, previous_record, uploader) do
    new_files = uploader.do_get_files(new_record)
    old_files = uploader.do_get_files(previous_record)

    new_files
    |> get_changed_files(old_files)
    |> do_delete_files(new_record, uploader)

    {:ok, new_record}
  end

  @doc """
  Deletes all files for a record. Used in delete functions.
  """
  def delete_files(record, uploader) do
    record
    |> uploader.do_get_files()
    |> do_delete_files(record, uploader)
  end

  defp do_delete_files(files, record, uploader) when is_list(files) do
    # Delete always returns :ok
    Enum.each(files, fn file ->
      :ok = uploader.delete({file, record})
    end)
  end

  # Returns all old files that are not in new files.
  defp get_changed_files(new_files, old_files) do
    old_files -- new_files
  end
end
