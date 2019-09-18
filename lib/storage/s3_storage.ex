defmodule Uploadex.S3Storage do
  @moduledoc """
  File storage.

  opts:
    bucket: string!
    directory: string!
    upload_opts: keyword list
    base_url: string! for get_url
  """

  @behaviour Uploadex.Storage

  alias ExAws.S3

  @impl true
  def store(%{filename: filename, path: path}, opts) do
    bucket = Keyword.fetch!(opts, :bucket)
    directory = Keyword.fetch!(opts, :directory)
    upload_opts = Keyword.get(opts, :upload_opts, [])

    path
    |> S3.Upload.stream_file()
    |> S3.upload(bucket, full_path(filename, directory), upload_opts)
    |> ExAws.request()
    |> convert_s3_result()
  end

  def store(%{filename: filename, binary: binary}, opts) do
    bucket = Keyword.fetch!(opts, :bucket)
    directory = Keyword.fetch!(opts, :directory)
    upload_opts = Keyword.get(opts, :upload_opts, [])

    bucket
    |> S3.put_object(full_path(filename, directory), binary, upload_opts)
    |> ExAws.request()
    |> convert_s3_result()
  end

  @impl true
  def delete(%{filename: filename}, opts), do: delete(filename, opts)
  def delete(filename, opts) when is_binary(filename) do
    bucket = Keyword.fetch!(opts, :bucket)
    directory = Keyword.fetch!(opts, :directory)

    bucket
    |> S3.delete_object(full_path(filename, directory))
    |> ExAws.request()
    |> convert_s3_result()
  end

  @impl true
  def get_url(%{filename: filename}, opts), do: get_url(filename, opts)
  def get_url(filename, opts) when is_binary(filename) do
    base_url = Keyword.fetch!(opts, :base_url)
    directory = Keyword.fetch!(opts, :directory)

    base_url
    |> Path.join(directory)
    |> Path.join(filename)
  end

  defp convert_s3_result({:ok, _}), do: :ok
  defp convert_s3_result(error), do: error

  defp full_path(filename, directory), do: Path.join(directory, filename)
end
