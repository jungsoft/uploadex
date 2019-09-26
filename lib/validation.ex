defmodule Uploadex.Validation do
  @moduledoc false

  @spec validate_extensions(list(any()), any()) :: :ok | {:error, any()}
  def validate_extensions(files, accepted_extensions) do
    case all_extensions_accepted?(files, accepted_extensions) do
      true ->
        :ok

      false ->
        {:error, "Some files in #{inspect(get_file_names(files))} violate the accepted extensions: #{inspect(accepted_extensions)}"}
    end
  end

  defp all_extensions_accepted?(_files, :any), do: true
  defp all_extensions_accepted?(files, extensions) do
    list_extensions = List.wrap(extensions)
    Enum.all?(files, & extension_accepted?(&1, list_extensions))
  end

  defp extension_accepted?(%{filename: filename}, accepted_extensions), do: extension_accepted?(filename, accepted_extensions)
  defp extension_accepted?(filename, accepted_extensions) when is_binary(filename) do
    extension = filename |> Path.extname() |> String.downcase()
    Enum.member?(accepted_extensions, extension)
  end

  def get_file_names(files) do
    Enum.map(files, fn
      %{filename: filename} -> filename
      filename -> filename
    end)
  end
end
