defmodule Uploadex.Resolver do
  @moduledoc """
  Resolver functions to make it easier to use Uploadex with Absinthe.

  ## Example

    In your Absinthe schema, assuming user only has one photo:

      object :user do
        field :photo_url, :string, resolve: Uploadex.Resolver.get_file_url(:photo)
      end

    If it has many photos:

      object :user do
        field :photos, list_of(:string), resolve: Uploadex.Resolver.get_files_url(:photos)
      end
  """

  alias Uploadex.Files

  @spec get_file_url(any) :: (any, any, any -> {:ok, any})
  def get_file_url(field) do
    fn record, _, _ ->
      {status, result} = Files.get_files_url(record, field)

      {status, result |> List.wrap() |> List.first()}
    end
  end

  @spec get_files_url(any) :: (any, any, any -> {:ok, [any]})
  def get_files_url(field) do
    fn record, _, _ -> Files.get_files_url(record, field) end
  end
end
