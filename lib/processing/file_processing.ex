defmodule Uploadex.FileProcessing do
  @moduledoc """
  Process files in Base64
  """

  @doc """
  This function currently only supports binaries in base 64 because it's not clear what are the other use cases for this.
  """
  @spec process_base64(String.t()) :: {:ok, binary()} | :error | {:error, keyword()}
  def process_base64(image_binary) do
    case String.split(image_binary, ";base64,") do
      [_metadata, base64] -> Base.decode64(base64)
      _ -> {:error, [encoding: "Only images in Base 64 are supported."]}
    end
  end
end
