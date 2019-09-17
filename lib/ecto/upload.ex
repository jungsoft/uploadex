defmodule Uploadex.Upload do
  @moduledoc """
  Ecto type that handles upload.

  It stores the filename in the database.
  """

  @behaviour Ecto.Type

  alias Uploadex.FileProcessing

  def type, do: :string

  def cast(%{filename: filename, path: path}) do
    {:ok, %{
      filename: generate_filename(filename),
      path: path
    }}
  end

  def cast(%{filename: filename, binary: binary}) do
    case FileProcessing.process_base64(binary) do
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

  defp generate_filename(filename), do: "#{Ecto.UUID.generate()}-#{filename}"

  def load(filename) when is_binary(filename), do: {:ok, filename}
  def load(_), do: :error

  def dump(%{filename: filename}), do: {:ok, filename}
  def dump(filename) when is_binary(filename), do: {:ok, filename}
  def dump(_), do: :error
end
