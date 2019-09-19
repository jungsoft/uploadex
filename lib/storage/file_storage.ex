defmodule Uploadex.FileStorage do
  @moduledoc """
  Storage for AWS S3.

  ## Opts

  * `directory`: String (required for all functions) - Relative to `base_path`
  * `base_path`: String (required for all functions)
  * `base_url`:  String (required for `c:Uploadex.Storage.get_url/2`)

  To build the URL, `base_path` will be replaced by `base_url`.

  ## Example

    To use this storage for your `User` record, define these functions in your `Uploadex.Uploader` implementation:

      def default_opts(Uploadex.FileStorage), do: [base_path: :code.priv_dir(:my_app), base_url: Endpoint.url()]

      def storage(%User{} = user), do: {Uploadex.FileStorage, directory: "/uploads/users"}
  """

  @behaviour Uploadex.Storage

  @impl true
  def store(file, opts) do
    full_path = get_full_path(opts)

    File.mkdir_p!(full_path)
    store_file(file, full_path)
  end

  defp store_file(%{filename: filename, path: path}, directory), do: File.cp(path, full_path(filename, directory))
  defp store_file(%{filename: filename, binary: binary}, directory), do: File.write(full_path(filename, directory), binary)

  defp full_path(filename, directory), do: Path.join(directory, filename)

  @impl true
  def delete(%{filename: filename}, opts), do: delete(filename, opts)
  def delete(filename, opts) when is_binary(filename) do
    full_path = get_full_path(opts)

    filename
    |> full_path(full_path)
    |> File.rm()
  end

  @impl true
  def get_url(%{filename: filename}, opts), do: get_url(filename, opts)
  def get_url(filename, opts) when is_binary(filename) do
    directory = Keyword.fetch!(opts, :directory)
    base_path = Keyword.fetch!(opts, :base_path)
    base_url = Keyword.fetch!(opts, :base_url)
    path = full_path(filename, directory)

    String.replace(path, base_path, base_url)
  end

  defp get_full_path(opts) do
    base_path = Keyword.fetch!(opts, :base_path)
    directory = Keyword.fetch!(opts, :directory)
    Path.join(base_path, directory)
  end
end
