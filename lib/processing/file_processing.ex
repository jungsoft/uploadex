defmodule Uploadex.FileProcessing do
  @moduledoc """
  Process files in Base64
  """

  @doc """
  If it's in base64, decode it. Otherwise, do not try to process the file.
  """
  @spec process_binary(String.t) :: {:ok, binary()} | :error | {:error, keyword()}
  def process_binary(image_binary) do
    case String.split(image_binary, ";base64,") do
      [_metadata, base64] -> Base.decode64(base64)
      _ -> {:ok, image_binary}
    end
  end
end
