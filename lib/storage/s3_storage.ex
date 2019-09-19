defmodule Uploadex.S3Storage do
  @moduledoc """
  Storage for AWS S3.

  ## Opts

  * `bucket`: String (required for `c:Uploadex.Storage.store/2` and `c:Uploadex.Storage.delete/2`)
  * `directory`: String (required for all functions)
  * `upload_opts`: Keyword list. This opts are passed to `ExAws.S3.upload/4` and `ExAws.S3.put_object/4` (required for `c:Uploadex.Storage.store/2`)
  * `base_url`:  String (required for `c:Uploadex.Storage.get_url/2`)

  ## Example

    To use this storage for your `User` record, define these functions in your `Uploadex.Uploader` implementation:

      def default_opts(Uploadex.S3Storage), do: [bucket: "my_bucket", base_url: "https://my_bucket.s3-sa-east-1.amazonaws.com", upload_opts: [acl: :public_read]]

      def storage(%User{} = user), do: {Uploadex.S3Storage, directory: "/photos"}
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
