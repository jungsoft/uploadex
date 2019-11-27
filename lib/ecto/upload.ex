defmodule Uploadex.Upload do
  @moduledoc """
  Ecto type that handles upload.

  It stores the filename in the database.
  """

  @behaviour Ecto.Type

  @type upload_path :: %{filename: String.t(), path: Path.t()}
  @type upload_binary :: %{filename: String.t(), binary: String.t()}

  alias Uploadex.FileProcessing

  @impl true
  def type, do: :string

  @spec cast(upload_path | upload_binary) :: {:ok, upload_path} | {:ok, upload_binary} | :error | {:error, keyword()}
  @impl true
  def cast(%{filename: filename, path: path}) do
    {:ok, %{
      filename: generate_filename(filename),
      path: path
    }}
  end

  def cast(%{filename: filename, binary: binary}) do
    case FileProcessing.process_binary(binary) do
      {:ok, binary} ->
        {:ok, %{
          filename: generate_filename(filename),
          binary: binary
        }}

      error ->
        error
    end
  end

  def cast(filename) when is_binary(filename), do: {:ok, filename}

  def cast(_), do: :error

  defp generate_filename(filename), do: Ecto.UUID.generate() <> Path.extname(filename)

  @spec load(any) :: :error | {:ok, binary}
  @impl true
  def load(filename) when is_binary(filename), do: {:ok, filename}
  def load(_), do: :error

  @spec dump(any) :: :error | {:ok, any}
  @impl true
  def dump(%{filename: filename}), do: {:ok, filename}
  def dump(filename) when is_binary(filename), do: {:ok, filename}
  def dump(_), do: :error

  @impl true
  def equal?(file1, file2) do
    get_filename(file1) == get_filename(file2)
  end

  defp get_filename(%{filename: filename}), do: filename
  defp get_filename(filename), do: filename

  @impl true
  def embed_as(_format), do: :dump
end
