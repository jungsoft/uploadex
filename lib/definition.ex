defmodule Uploadex.Definition do

  alias Uploadex.Uploader

  defmacro __using__(opts \\ []) do
    repo = Keyword.fetch!(opts, :repo)

    quote do
      @behaviour Uploader

      use Arc.Definition

      def repo, do: unquote(repo)

      @doc """
      Wraps the user defined `get_files` function to always return a list
      """
      def do_get_files(record) do
        record
        |> get_files()
        |> List.wrap()
        |> Enum.reject(&is_nil/1)
      end

      defoverridable Uploader
    end
  end
end
