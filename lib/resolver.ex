defmodule Uploadex.Resolver do
  @moduledoc """
  Resolver functions to make it easier to use Uploadex with Absinthe.
  """

  def get_file_url(record, _, _) do
    record
    |> Uploadex.get_files_url()
    |> convert_list_result("get_files_url/3")
  end

  def get_file_url(record, file) do
    record
    |> Uploadex.get_files_url(file)
    |> convert_list_result("get_files_url/2")
  end

  defp convert_list_result(result, function_name) do
    case result do
      [file] -> {:ok, file}
      [] -> {:ok, nil}
      _ -> {:error, "Use #{function_name} to get the URLs when the record has multiple files"}
    end
  end

  def get_files_url(record, _, _) do
    {:ok, Uploadex.get_files_url(record)}
  end

  def get_files_url(record, files) do
    {:ok, Uploadex.get_files_url(record, files)}
  end
end
