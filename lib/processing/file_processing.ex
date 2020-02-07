defmodule Uploadex.FileProcessing do
  @moduledoc """
  Process files in Base64
  """

  @doc """
  If it's in base64, decode it. Otherwise, do not try to process the file.
  """
  @spec process_binary(String.t) :: {String.t, {:ok, binary()}} | :error | {:error, keyword() | String.t}
  def process_binary(image_binary) do
    case String.split(image_binary, ";base64,") do
      [metadata, base64] -> {String.replace(metadata, "data:", ""), Base.decode64(base64)}
      _ -> {:error, "Invalid base64 format"}
    end
  end
end
