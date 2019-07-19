defmodule Uploadex.Storage.Local do
  @moduledoc """
  Local storage.
  Use this module instead of arc's to have the same pattern between upload and fetch.

  The problem is that to upload, arc expects a mao with the key :filename, but when fetching it expects a :file_name,
  so you can't store a record with an upload and then take the result to get the file.
  """

  def put(definition, version, {file, scope}) do
    destination_dir = definition.storage_dir(version, {file, scope})
    filename =
      version
      |> definition.filename({file, scope})
      |> Kernel.<>(definition.extension(version, {file, scope}))

    path = Path.join(destination_dir, filename)
    path |> Path.dirname() |> File.mkdir_p!()

    if binary = file.binary do
      File.write!(path, binary)
    else
      File.copy!(file.path, path)
    end

    {:ok, filename}
  end

  def url(definition, version, file_and_scope, _options \\ []) do
    definition
    |> build_local_path(version, file_and_scope)
    |> add_forward_slash_to_path
    |> URI.encode()
  end

  def delete(definition, version, file_and_scope) do
    definition
    |> build_local_path(version, file_and_scope)
    |> File.rm()
  end

  defp build_local_path(definition, version, file_and_scope) do
    Path.join([
      definition.storage_dir(version, file_and_scope),
      definition.resolve_file_name(version, file_and_scope)
    ])
  end

  defp add_forward_slash_to_path("/" <> local_path), do: local_path
  defp add_forward_slash_to_path(local_path), do: "/" <> local_path
end
