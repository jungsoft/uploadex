defmodule Uploadex.Files do
  @moduledoc """
  Functions to store and delete files.

  Note that all functions in this module require the Uploader as an argument. You are free to call them like that:

      iex> Uploadex.Files.store_files(user, MyUploader)
      {:ok, %User{}}

  However, by doing `use Uploadex` in your uploader, you can call these functions directly through the uploader to avoid having to pass this
  extra argument around:

      iex> MyUploader.store_files(user)
      {:ok, %User{}}
  """

  @type record :: any()
  @type record_field :: atom()
  @type status :: :ok | :error

  alias Uploadex.{
    Validation,
    Uploader,
  }

  @doc """
  Stores all files of a record, as defined by the uploader.

  Files that are not maps are ignored, which allows for assigning an existing file to a record without recreating it, by simply passing it's filename.
  """
  @spec store_files(record, Uploader.t) :: {:ok, record} | {:error, any()}
  def store_files(record, uploader) do
    files = wrap_files(record, uploader)
    extensions = get_accepted_extensions(record, uploader)

    case Validation.validate_extensions(files, extensions) do
      :ok ->
        files
        |> Enum.filter(fn {file, _, _} -> is_map(file) end)
        |> do_store_files(record)

      error -> error
    end
  end

  # Recursively stores all files, stopping if one operation fails.
  defp do_store_files([{file, _field, {storage, opts}} | remaining_files], record) do
    case apply(storage, :store, [file, opts]) do
      :ok -> do_store_files(remaining_files, record)
      {:error, error} -> {:error, error}
    end
  end

  defp do_store_files([], record) do
    {:ok, record}
  end

  @doc """
  Deletes all files that changed.
  """
  @spec delete_previous_files(record, record, Uploader.t) :: {:ok, record} | {:error, any()}
  def delete_previous_files(new_record, previous_record, uploader) do
    new_files = wrap_files(new_record, uploader)
    old_files = wrap_files(previous_record, uploader)

    new_files
    |> get_changed_files(old_files)
    |> do_delete_files(new_record)
  end

  @doc """
  Deletes all files for a record.
  """
  @spec delete_files(record, Uploader.t) :: {:ok, record} | {:error, any()}
  def delete_files(record, uploader) do
    record
    |> wrap_files(uploader)
    |> do_delete_files(record)
  end

  defp do_delete_files(files, record) do
    Enum.each(files, fn {file, _field, {storage, opts}} -> apply(storage, :delete, [file, opts]) end)
    {:ok, record}
  end

  # Returns all old files that are not in new files.
  defp get_changed_files(new_files, old_files) do
    old_files -- new_files
  end

  @spec get_file_url(record, String.t, record_field, Uploader.t) :: {status, String.t | nil}
  def get_file_url(record, file, field, uploader) do
    {status, result} = get_files_url(record, file, field, uploader)

    {status, List.first(result)}
  end

  @spec get_files_url(record, record_field, Uploader.t) :: {status, [String.t]}
  def get_files_url(record, field, uploader) do
    get_files_url(record, wrap_files(record, uploader, field), field, uploader)
  end

  @spec get_files_url(record, String.t | [String.t], record_field, Uploader.t) :: {status, [String.t]}
  def get_files_url(record, files, field, uploader) do
    files
    |> List.wrap()
    |> Enum.map(fn
      %{filename: _filename} = file ->
        {storage, opts} = get_storage_opts(record, field, uploader)
        apply(storage, :get_url, [file, opts])

      {file, _field, {storage, opts}} ->
        apply(storage, :get_url, [file, opts])
    end)
    |> Enum.group_by(& elem(&1, 0), & elem(&1, 1))
    |> case do
      %{error: errors} -> {:error, errors}
      %{ok: urls} -> {:ok, urls}
      %{} -> {:ok, []}
    end
  end

  @spec get_temporary_file(record, String.t, String.t, record_field, Uploader.t) :: String.t | nil | {:error, String.t}
  def get_temporary_file(record, file, path, field, uploader) do
    record
    |> get_temporary_files(file, path, field, uploader)
    |> List.first()
  end

  @spec get_temporary_files(record, String.t, record_field, Uploader.t) :: [String.t]
  def get_temporary_files(record, path, field, uploader) do
    get_temporary_files(record, wrap_files(record, uploader), path, field, uploader)
  end

  @spec get_temporary_files(record, String.t | [String.t], String.t, record_field, Uploader.t) :: [String.t]
  def get_temporary_files(record, files, path, field, uploader) do
    files
    |> List.wrap()
    |> Enum.map(fn
      %{filename: _filename} = file ->
        {storage, opts} = get_storage_opts(record, field, uploader)
        apply(storage, :get_temporary_file, [file, path, opts])

      {file, _field, {storage, opts}} ->
        apply(storage, :get_temporary_file, [file, path, opts])
    end)
  end

  # Get storage opts considering default values
  defp get_storage_opts(record, field, uploader) do
    {storage, opts} = uploader.storage(record, field)
    default_opts = uploader.default_opts(storage)

    {storage, Keyword.merge(default_opts, opts)}
  end

  # Wraps the user defined `get_fields` function to always return a list
  defp wrap_files(record, uploader, field \\ nil) do
    field
    |> Kernel.||(uploader.get_fields(record))
    |> List.wrap()
    |> Enum.map(fn field ->
      case Map.get(record, field) do
        result when is_list(result) -> Enum.map(result, & ({&1, field, get_storage_opts(record, field, uploader)}))
        result when is_map(result) -> {result, field, get_storage_opts(record, field, uploader)}
        result when is_binary(result) -> {result, field, get_storage_opts(record, field, uploader)}
        nil -> nil
      end
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  defp get_accepted_extensions(record, uploader) do
    case function_exported?(uploader, :accepted_extensions, 2) do
      true ->
        record
        |> uploader.get_fields()
        |> List.wrap()
        |> Enum.into(%{}, fn field -> {field, uploader.accepted_extensions(record, field)} end)

      false ->
        :any
    end
  end
end
