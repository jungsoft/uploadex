defmodule Uploadex.S3Storage do
  @moduledoc """
  Storage for AWS S3.

  ## Opts

  * `bucket`: String (required for all functions)
  * `region`:  String (required for `c:Uploadex.Storage.get_url/2`)
  * `directory`: String (required for all functions)
  * `upload_opts`: Keyword list. This opts are passed to `ExAws.S3.upload/4` and `ExAws.S3.put_object/4` (required for `c:Uploadex.Storage.store/2`).
      If `content_type` is not specified in `upload_opts`, the default is the upload's content type.

  ## Example

    To use this storage for your `User` record, define these functions in your `Uploadex.Uploader` implementation:

      def default_opts(Uploadex.S3Storage), do: [bucket: "my_bucket", region: "sa-east-1", upload_opts: [acl: :public_read]]

      def storage(%User{} = user, :photo), do: {Uploadex.S3Storage, directory: "/photos"}
  """

  @behaviour Uploadex.Storage

  alias ExAws.S3

  @impl true
  def store(%{filename: filename, path: path, content_type: content_type}, opts) do
    bucket = Keyword.fetch!(opts, :bucket)
    directory = Keyword.fetch!(opts, :directory)
    upload_opts =
      opts
      |> Keyword.get(:upload_opts, [])
      |> Keyword.put_new(:content_type, content_type)

    path
    |> S3.Upload.stream_file()
    |> S3.upload(bucket, full_path(filename, directory), upload_opts)
    |> ExAws.request()
    |> convert_s3_result()
  end

  def store(%{filename: filename, binary: binary, content_type: content_type}, opts) do
    bucket = Keyword.fetch!(opts, :bucket)
    directory = Keyword.fetch!(opts, :directory)
    upload_opts =
      opts
      |> Keyword.get(:upload_opts, [])
      |> Keyword.put_new(:content_type, content_type)

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
    bucket = Keyword.fetch!(opts, :bucket)
    directory = Keyword.fetch!(opts, :directory)
    config_s3 = Keyword.get(opts, :config_s3, [])

    :s3
    |> ExAws.Config.new()
    |> ExAws.S3.presigned_url(:get, bucket, Path.join(directory, filename), config_s3)
  end

  @impl true
  def get_temporary_file(%{filename: filename}, path, opts), do: get_temporary_file(filename, path, opts)
  def get_temporary_file(filename, path, opts) when is_binary(filename) do
    bucket = Keyword.fetch!(opts, :bucket)
    directory = Keyword.fetch!(opts, :directory)
    delay = Keyword.get(opts, :delete_after, :timer.seconds(30))
    s3_path = Path.join(directory, filename)

    destination_file = Ecto.UUID.generate() <> Path.extname(filename)
    destination_path = Path.join(path, destination_file)

    bucket |> S3.download_file(s3_path, destination_path) |> ExAws.request!()
    delete_file_after_delay(delay, destination_path)

    destination_path
  end

  defp delete_file_after_delay(delay, path) do
    :timer.apply_after(delay, File, :rm, [path])
  end

  defp convert_s3_result({:ok, _}), do: :ok
  defp convert_s3_result(error), do: error

  defp full_path(filename, directory), do: Path.join(directory, filename)
end
