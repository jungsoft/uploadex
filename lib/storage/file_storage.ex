defmodule Uploadex.FileStorage do
  @moduledoc """
  File storage.

  opts:
    directory: string!
    base_path: string! for get_url
    base_url: string! for get_url
  """

  @behaviour Uploadex.Storage

  @impl true
  def store(file, opts) do
    directory = Keyword.fetch!(opts, :directory)

    File.mkdir_p!(directory)
    store_file(file, directory)
  end

  defp store_file(%{filename: filename, path: path}, directory), do: File.cp(path, full_path(filename, directory))
  defp store_file(%{filename: filename, binary: binary}, directory), do: File.write(full_path(filename, directory), binary)

  defp full_path(filename, directory), do: Path.join(directory, filename)

  @impl true
  def delete(%{filename: filename}, opts), do: delete(filename, opts)
  def delete(filename, opts) when is_binary(filename) do
    directory = Keyword.fetch!(opts, :directory)

    filename
    |> full_path(directory)
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
end
