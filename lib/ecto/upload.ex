defmodule Uploadex.Upload do
  @moduledoc """
  Ecto type that handles upload.

  It stores the filename in the database.
  """

  @behaviour Ecto.Type

  @type upload_path :: %{filename: String.t(), path: Path.t()}
  @type upload_binary :: %{filename: String.t(), binary: String.t()}

  alias Uploadex.FileProcessing

  def type, do: :string

  @spec cast(upload_path | upload_binary) :: {:ok, upload_path} | {:ok, upload_binary} | :error | {:error, keyword()}
  def cast(%{filename: _filename, path: path}) do
    {:ok, %{
      filename: generate_filename(),
      path: path
    }}
  end

  def cast(%{filename: _filename, binary: binary}) do
    case FileProcessing.process_binary(binary) do
      {:ok, binary} ->
        {:ok, %{
          filename: generate_filename(),
          binary: binary
        }}

      error ->
        error
    end
  end

  def cast(filename) when is_binary(filename), do: {:ok, filename}

  def cast(_), do: :error

  defp generate_filename, do: Ecto.UUID.generate()

  @spec load(any) :: :error | {:ok, binary}
  def load(filename) when is_binary(filename), do: {:ok, filename}
  def load(_), do: :error

  @spec dump(any) :: :error | {:ok, any}
  def dump(%{filename: filename}), do: {:ok, filename}
  def dump(filename) when is_binary(filename), do: {:ok, filename}
  def dump(_), do: :error
end
