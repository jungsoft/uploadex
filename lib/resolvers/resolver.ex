defmodule Uploadex.Resolver do
  @moduledoc """
  Resolver functions to make it easier to use Uploadex with Absinthe.

  Note that all functions in this module require the Uploader as an argument. You are free to call them like that:

  ## Example

    In your Absinthe schema, assuming user only has one photo:

      object :user do
        field :photo_url, :string, resolve: Uploadex.Resolver.get_file_url(:photo, MyUploader)
      end

    If it has many photos:

      object :user do
        field :photos, list_of(:string), resolve: Uploadex.Resolver.get_files_url(:photos, MyUploader)
      end

  However, by doing `use Uploadex` in your uploader, you can call these functions directly through the uploader to avoid having to pass this
  extra argument around:

  ## Example

    In your Absinthe schema, assuming user only has one photo:

      object :user do
        field :photo_url, :string, resolve: MyUploader.get_file_url(:photo)
      end

    If it has many photos:

      object :user do
        field :photos, list_of(:string), resolve: MyUploader.get_files_url(:photos)
      end
  """

  alias Uploadex.Uploader

  @spec get_file_url(atom, Uploader.t) :: (any, any, any -> {:ok, any})
  def get_file_url(field, uploader) do
    fn record, _, _ ->
      {status, result} = uploader.get_files_url(record, field)
      {status, result |> List.wrap() |> List.first()}
    end
  end

  @spec get_files_url(atom, Uploader.t) :: (any, any, any -> {:ok, [any]})
  def get_files_url(field, uploader) do
    fn record, _, _ -> uploader.get_files_url(record, field) end
  end
end
