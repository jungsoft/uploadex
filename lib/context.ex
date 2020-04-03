defmodule Uploadex.Context do
  @moduledoc """
  Context Helper functions for handling files.
  """

  alias Ecto.Multi

  @doc """
  Inserts the changeset and store the record files in a database transaction,
  so if the files fail to be stored the record will not be created.
  """
  def create_with_file(changeset, repo, uploader, opts \\ []) do
    Multi.new()
    |> Multi.run(:insert, fn _repo, _ -> repo.insert(changeset, opts) end)
    |> Multi.run(:store_files, fn _repo, %{insert: record} -> uploader.store_files(record) end)
    |> repo.transaction()
    |> convert_result()
  end

  @doc """
  Updates the record and its files in a database transaction,
  so if the files fail to be stored the record will not be created.

  This function also deletes files that are no longer referenced.
  """
  def update_with_file(changeset, previous_record, repo, uploader, opts \\ []) do
    Multi.new()
    |> Multi.run(:update, fn _repo, _ -> repo.update(changeset, opts) end)
    |> Multi.run(:store_files, fn _repo, %{update: record} -> uploader.store_files(record) end)
    |> Multi.run(:delete_file, fn _repo, %{update: record} -> uploader.delete_previous_files(record, previous_record) end)
    |> repo.transaction()
    |> convert_result()
  end

  @doc """
  Similar to `update_with_file/3`, but does not delete previous files.
  """
  def update_with_file_keep_previous(changeset, repo, uploader, opts \\ []) do
    Multi.new()
    |> Multi.run(:update, fn _repo, _ -> repo.update(changeset, opts) end)
    |> Multi.run(:store_files, fn _repo, %{update: record} -> uploader.store_files(record) end)
    |> repo.transaction()
    |> convert_result()
  end

  @doc """
  Deletes the record and all of its files.
  This is not in a database transaction, since the delete operation never returns errors.
  """
  def delete_with_file(record, repo, uploader, opts \\ []) do
    case repo.delete(record, opts) do
      {:ok, record} -> uploader.delete_files(record)
      {:error, error} -> {:error, error}
    end
  end

  defp convert_result({:error, _, msg, _}), do: {:error, msg}
  defp convert_result({:ok, %{insert: record}}), do: {:ok, record}
  defp convert_result({:ok, %{update: record}}), do: {:ok, record}
end
