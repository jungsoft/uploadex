defmodule Uploadex.FileStorage do
  @moduledoc """
  Storage for Local Files.

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
    full_path = get_full_path_directory(opts)

    File.mkdir_p!(full_path)
    store_file(file, full_path)
  end

  defp store_file(%{filename: filename, path: path}, directory), do: File.cp(path, Path.join(directory, filename))
  defp store_file(%{filename: filename, binary: binary}, directory), do: directory |> Path.join(filename) |> File.write(binary)

  @impl true
  def delete(%{filename: filename}, opts), do: delete(filename, opts)
  def delete(filename, opts) when is_binary(filename) do
    opts
    |> get_file_full_path(filename)
    |> File.rm()
  end

  @impl true
  def get_url(%{filename: filename}, opts), do: get_url(filename, opts)
  def get_url(filename, opts) when is_binary(filename) do
    full_path = get_file_full_path(opts, filename)

    base_path = Keyword.fetch!(opts, :base_path)
    base_url = Keyword.fetch!(opts, :base_url)

    String.replace(full_path, base_path, base_url)
  end

  @impl true
  def get_temporary_file(%{filename: filename}, path, opts), do: get_temporary_file(filename, path, opts)
  def get_temporary_file(filename, path, opts) when is_binary(filename) do
    delay = Keyword.get(opts, :delete_after, 30_000)
    full_path = get_file_full_path(opts, filename)

    destination_file = Ecto.UUID.generate() <> Path.extname(filename)
    destination_path = Path.join(path, destination_file)

    File.cp!(full_path, destination_path)
    delete_file_after_delay(delay, destination_path)
  end

  def delete_file_after_delay(delay, path) do
    TaskAfter.task_after(delay, fn -> File.rm(path) end)
    path
  end

  defp get_file_full_path(opts, filename) do
    opts
    |> get_full_path_directory()
    |> Path.join(filename)
  end

  defp get_full_path_directory(opts) do
    base_path = Keyword.fetch!(opts, :base_path)
    directory = Keyword.fetch!(opts, :directory)
    Path.join(base_path, directory)
  end
end
