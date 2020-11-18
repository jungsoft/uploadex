defmodule Uploadex.Validation do
  @moduledoc false


  @type file :: map() | String.t
  @type field :: atom()
  @type storage_opts :: any()
  @type wrapped_file :: {file(), field(), storage_opts()}

  @spec validate_extensions([wrapped_file], [String.t] | any) :: :ok | {:error, any()}
  def validate_extensions(_files, :any), do: :ok

  def validate_extensions(files, accepted_extensions) do
    files
    |> Enum.group_by(fn {_file, field, _storage} -> field end)
    |> Enum.map(fn {field, files} ->
      accepted_extensions = if is_map(accepted_extensions), do: Map.get(accepted_extensions, field, []), else: accepted_extensions
      case all_extensions_accepted?(files, accepted_extensions) do
        true ->
          {:ok, true}

        false ->
          {:error, "Some files in #{inspect(get_file_names(files))} violate the accepted extensions: #{inspect(accepted_extensions)}"}
      end
    end)
    |> Enum.filter(fn {status, _msg} -> status == :error  end)
    |> case do
      [] -> :ok
      [_|_] = errors ->  {:error, Enum.map_join(errors, "; ", fn {_status, msg} -> msg end)}
    end
  end

  defp all_extensions_accepted?(_files, :any), do: true

  defp all_extensions_accepted?(files, extensions) do
    list_extensions = List.wrap(extensions)
    Enum.all?(files, & extension_accepted?(&1, list_extensions))
  end

  defp extension_accepted?({%{filename: filename}, _field, _storage}, accepted_extensions), do: extension_accepted?(filename, accepted_extensions)
  defp extension_accepted?({filename, _field, _storage}, accepted_extensions), do: extension_accepted?(filename, accepted_extensions)
  defp extension_accepted?(filename, accepted_extensions) when is_binary(filename) do
    extension = filename |> Path.extname() |> String.downcase()
    Enum.member?(accepted_extensions, extension)
  end

  defp get_file_names(files) do
    Enum.map(files, fn
      {%{filename: filename}, _field, _storage} -> filename
      {filename, _field, _storage} -> filename
    end)
  end
end
