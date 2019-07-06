defmodule Uploadex.Definition do

  alias Uploadex.Uploader

  defmacro __using__(opts \\ []) do
    repo = Keyword.fetch!(opts, :repo)

    quote do
      @behaviour Uploader

      use Arc.Definition

      def get_files(record), do: record.photo
      def repo, do: unquote(repo)

      @doc """
      Wraps the user defined `get_files` function to always return a list
      """
      def do_get_files(record) do
        case get_files(record) do
          nil -> []
          files when is_list(files) -> Enum.reject(files, &is_nil/1)
          file -> [file]
        end
      end

      defoverridable Uploader
    end
  end
end
