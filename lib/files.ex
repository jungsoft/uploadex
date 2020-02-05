defmodule Uploadex.Files do
  @moduledoc """
  Functions to store and delete files.
  """

  @type record :: any()
  @type record_field :: atom()
  @type status :: :ok | :error

  alias Uploadex.Validation

  defp uploader!, do: Application.fetch_env!(:uploadex, :uploader)

  @doc """
  Stores all files of a record, as defined by the uploader.

  Files that are not maps are ignored, which allows for assigning an existing file to a record without recreating it, by simply passing it's filename.
  """
  @spec store_files(record) :: {:ok, record} | {:error, any()}
  def store_files(record) do
    files = wrap_files(record)
    extensions = get_accepted_extensions(record)

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
  @spec delete_previous_files(record, record) :: {:ok, record} | {:error, any()}
  def delete_previous_files(new_record, previous_record) do
    new_files = wrap_files(new_record)
    old_files = wrap_files(previous_record)

    new_files
    |> get_changed_files(old_files)
    |> do_delete_files(new_record)
  end

  @doc """
  Deletes all files for a record.
  """
  @spec delete_files(record) :: {:ok, record} | {:error, any()}
  def delete_files(record) do
    record
    |> wrap_files()
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

  @spec get_file_url(record, String.t, record_field) :: {status, String.t | nil}
  def get_file_url(record, file, field) do
    {status, result} = get_files_url(record, file, field)

    {status, List.first(result)}
  end

  @spec get_files_url(record, record_field) :: {status, [String.t]}
  def get_files_url(record, field) do
    get_files_url(record, wrap_files(record, field), field)
  end

  @spec get_files_url(record, String.t | [String.t], record_field) :: {status, [String.t]}
  def get_files_url(record, files, field) do
    files
    |> List.wrap()
    |> Enum.map(fn
      %{filename: _filename} = file ->
        {storage, opts} = get_storage_opts(record, field)
        apply(storage, :get_url, [file, opts])

      {file, _field, {storage, opts}} ->
        apply(storage, :get_url, [file, opts])
    end)
    |> Enum.group_by(& elem(&1, 0), & elem(&1, 1))
    |> case do
      %{error: errors} -> {:error, errors}
      %{ok: urls} -> {:ok, urls}
    end
  end

  @spec get_temporary_file(record, String.t, String.t, record_field) :: String.t | nil | {:error, String.t}
  def get_temporary_file(record, file, path, field) do
    record
    |> get_temporary_files(file, path, field)
    |> List.first()
  end

  @spec get_temporary_files(record, String.t, record_field) :: [String.t]
  def get_temporary_files(record, path, field) do
    get_temporary_files(record, wrap_files(record), path, field)
  end

  @spec get_temporary_files(record, String.t | [String.t], String.t, record_field) :: [String.t]
  def get_temporary_files(record, files, path, field) do
    files
    |> List.wrap()
    |> Enum.map(fn
      %{filename: _filename} = file ->
        {storage, opts} = get_storage_opts(record, field)
        apply(storage, :get_temporary_file, [file, path, opts])

      {file, _field, {storage, opts}} ->
        apply(storage, :get_temporary_file, [file, path, opts])
    end)
  end

  # Get storage opts considering default values
  defp get_storage_opts(record, field) do
    {storage, opts} = uploader!().storage(record, field)
    default_opts = uploader!().default_opts(storage)

    {storage, Keyword.merge(default_opts, opts)}
  end

  # Wraps the user defined `get_fields` function to always return a list
  defp wrap_files(record, field \\ nil) do
    uploader = uploader!()

    field
    |> Kernel.||(uploader.get_fields(record))
    |> List.wrap()
    |> Enum.map(fn field ->
      case Map.get(record, field) do
        result when is_list(result) -> Enum.map(result, & ({&1, field, get_storage_opts(record, field)}))
        result when is_map(result) -> {result, field, get_storage_opts(record, field)}
        result when is_binary(result) -> {result, field, get_storage_opts(record, field)}
        nil -> nil
      end
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  defp get_accepted_extensions(record) do
    case function_exported?(uploader!(), :accepted_extensions, 2) do
      true ->
        record
        |> uploader!().get_fields()
        |> List.wrap()
        |> Enum.into(%{}, fn field -> {field, uploader!().accepted_extensions(record, field)} end)

      false ->
        :any
    end
  end
end
