defmodule Uploadex.Resolver do
  @moduledoc """
  Resolver functions to make it easier to use Uploadex with Absinthe.

  ## Example

    In your Absinthe schema, assuming user only has one photo:

      object :user do
        field :photo_url, :string, resolve: &Uploadex.Resolver.get_file_url/3
      end

    If it has many photos:

      object :user do
        field :photos, list_of(:string), resolve: &Uploadex.Resolver.get_files_url/3
      end

    If an object has many files but the field is for a specific one:

      object :company do
        field :logo_url, :string, resolve: fn company, _, _ -> Uploadex.Resolver.get_file_url(company, company.logo) end
      end
  """

  alias Uploadex.Files

  @spec get_file_url(any) :: (any, any, any -> {:ok, any})
  def get_file_url(field) do
    fn record, _, _ -> {:ok, record |> Files.get_files_url(field) |> List.first()} end
  end

  @spec get_file_url(any, any, any) :: {:ok, any}
  def get_file_url(record, file, field) do
    {:ok, Files.get_file_url(record, file, field)}
  end

  @spec get_files_url(any) :: (any, any, any -> {:ok, [any]})
  def get_files_url(field) do
    fn record, _, _ -> {:ok, Files.get_files_url(record, field)} end
  end

  @spec get_files_url(any, any, any) :: {:ok, [any]}
  def get_files_url(record, files, field) do
    {:ok, Files.get_files_url(record, files, field)}
  end
end
