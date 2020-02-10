defmodule Uploadex.FileProcessing do
  @moduledoc """
  Process files in Base64
  """

  @invalid_format_message "Invalid base64 format"

  @doc """
  If it's in base64, decode it. Otherwise, do not try to process the file.
  """
  @type processed_binary :: %{binary: String.t, content_type: String.t}

  @spec process_binary(String.t) :: {:ok, processed_binary()} | {:error, String.t}
  def process_binary(image_binary) do
    with  [metadata, base64] <- String.split(image_binary, ";base64,"),
          {:ok, binary} <- Base.decode64(base64)
    do
      {:ok, %{binary: binary, content_type: String.replace(metadata, "data:", "")}}
    else
      [_base64] -> {:error, @invalid_format_message}
      [] -> {:error, @invalid_format_message}
      :error -> {:error, "Invalid base64"}
    end
  end
end
