defmodule Uploadex.Resolver do
  @moduledoc """
  Resolver functions to make it easier to use Uploadex with Absinthe.
  """

  alias Uploadex.Files

  @spec get_file_url(any, any, any) :: {:error, any} | {:ok, any}
  def get_file_url(record, _, _) do
    case Files.get_file_url(record) do
      {:error, error} -> {:error, error}
      file -> {:ok, file}
    end
  end

  @spec get_file_url(any, any) :: {:ok, any}
  def get_file_url(record, file) do
    {:ok, Files.get_file_url(record, file)}
  end

  @spec get_files_url(any, any, any) :: {:ok, [any]}
  def get_files_url(record, _, _) do
    {:ok, Files.get_files_url(record)}
  end

  @spec get_files_url(any, any) :: {:ok, [any]}
  def get_files_url(record, files) do
    {:ok, Files.get_files_url(record, files)}
  end
end
