defmodule Uploadex do
  @moduledoc """
  Context Helper functions for handling files.
  """

  alias Ecto.Multi
  alias Uploadex.Files

  @doc """
  Inserts the changeset and store the record files in a database transaction,
  so if the files fail to be stored the record will not be created.
  """
  def create_with_file(changeset, uploader, opts \\ []) do
    repo = uploader.repo

    Multi.new()
    |> Multi.run(:insert, fn _repo, _ -> repo.insert(changeset, opts) end)
    |> Multi.run(:store_files, fn _repo, %{insert: record} -> Files.store_files(record, uploader) end)
    |> repo.transaction()
    |> convert_result()
  end

  @doc """
  Updates the record and its files in a database transaction,
  so if the files fail to be stored the record will not be created.

  This function also deletes files that are no longer referenced.
  """
  def update_with_file(changeset, previous_record, uploader, opts \\ []) do
    repo = uploader.repo

    Multi.new()
    |> Multi.run(:update, fn _repo, _ -> repo.update(changeset, opts) end)
    |> Multi.run(:store_files, fn _repo, %{update: record} -> Files.store_files(record, uploader) end)
    |> Multi.run(:delete_file, fn _repo, %{update: record} -> Files.delete_previous_files(record, previous_record, uploader) end)
    |> repo.transaction()
    |> convert_result()
  end

  @doc """
  Similar to `update_with_file/3`, but does not delete previous files.
  """
  def update_with_file_keep_previous(changeset, uploader, opts \\ []) do
    repo = uploader.repo

    Multi.new()
    |> Multi.run(:update, fn _repo, _ -> repo.update(changeset, opts) end)
    |> Multi.run(:store_files, fn _repo, %{update: record} -> Files.store_files(record, uploader) end)
    |> repo.transaction()
    |> convert_result()
  end

  @doc """
  Deletes the record and all of its files.
  This is not in a database transaction, since the delete operation never returns errors.
  """
  def delete_with_file(record, uploader, opts \\ []) do
    repo = uploader.repo

    case repo.delete(record, opts) do
      {:ok, record} -> Files.delete_files(record, uploader)
      {:error, error} -> {:error, error}
    end
  end

  defp convert_result({:error, _, msg, _}), do: {:error, msg}
  defp convert_result({:ok, %{insert: record}}), do: {:ok, record}
  defp convert_result({:ok, %{update: record}}), do: {:ok, record}

  @doc """
  Returns the record's files (as defined in the definition `get_files`) URL, replacing the `uploader.base_directory()` with the endpoint URL.

  To provide the endpoint URL, there are two options:

    * Provide the `endpoint_url` directly as a string
    * Provide the `Phoenix.Endpoint` module
  """
  def get_files_url(uploader, record, endpoint_url) when is_binary(endpoint_url) do
    record
    |> uploader.do_get_files()
    |> Enum.map(fn file ->
      {file, record}
      |> uploader.url()
      |> String.replace(uploader.base_directory(), endpoint_url)
    end)
  end

  def get_files_url(uploader, record, endpoint) when is_atom(endpoint) do
    get_files_url(uploader, record, endpoint.url())
  end

  @doc """
  Similar to `get_files_url/3`, but instead of returning all files defined in the definition `get_files`, returns the URL for the specified files.

  This is useful when one record has multiple file fields.
  """
  def get_files_url(uploader, record, files, endpoint_url) when is_binary(endpoint_url) do
    files
    |> List.wrap()
    |> Enum.map(fn file ->
      {file, record}
      |> uploader.url()
      |> String.replace(uploader.base_directory(), endpoint_url)
    end)
  end

  def get_files_url(uploader, record, files, endpoint) when is_atom(endpoint) do
    get_files_url(uploader, record, files, endpoint.url())
  end
end
