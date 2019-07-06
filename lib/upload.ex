defmodule Uploadex.Upload do
  @moduledoc """
  Ecto type that handles upload
  """

  @behaviour Ecto.Type

  def type, do: :string

  # Cast a Plug.Upload
  def cast(%{filename: filename, path: path}) do
    {:ok, %{
      filename: "#{Ecto.UUID.generate()}-#{filename}",
      path: path
    }}
  end

  # Cast a file
  def cast(filename) when is_binary(filename), do: {:ok, filename}

  def cast(_), do: :error

  def load(filename) when is_binary(filename), do: {:ok, filename}
  def load(_), do: :error

  def dump(%{filename: filename}), do: {:ok, filename}
  def dump(filename) when is_binary(filename), do: {:ok, filename}
  def dump(_), do: :error
end
