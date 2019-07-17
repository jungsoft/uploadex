defmodule Uploadex.Definition do
  @moduledoc """
  An Uploader definition.

  This is a wrapper on top of the [Arc.Definition](https://github.com/stavro/arc/blob/master/lib/arc/definition.ex), adding some extra functionalities to it.

  ## Usage

      defmodule MyApp.MyUploader do
        use Uploadex.Definition,
          repo: MyApp.Repo

        ## Functions required for Uploadex.Definition

        def base_directory do
          Path.join(:code.priv_dir(:my_app), "static/")
        end

        def get_files(%MyApp.User{photo: photo}), do: photo
        def get_files(%MyApp.Company{} = company) do
          company
          |> MyApp.Repo.preload(:photos)
          |> Map.get(:photos)
          |> Enum.map(& &1.file)
        end

        ## We can also define the functions for Arc.Definition here

        def storage_dir(_version, {_file, %User{id: user_id}}) do
          Path.join(base_directory(), "/uploads/users/\#{user_id}")
        end

        def storage_dir(_version, {_file, %Company{id: id}}) do
          Path.join(base_directory(), "/uploads/companies/\#{id}")
        end
      end

  """

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

      def url(file), do: url(file, nil)
      def url(file, options) when is_list(options), do: url(file, nil, options)
      def url(file, version), do: url(file, version, [])
      def url(file, version, options), do: Path.join(storage_dir(version, file), filename(version, file))

      def filename(_version, {%{file_name: file_name}, _record}), do: Path.basename(file_name)
      def filename(_version, {%{filename: filename}, _record}), do: Path.basename(filename)
      def filename(_version, {filename, _record}) when is_binary(filename), do: Path.basename(filename)

      defoverridable Uploader
    end
  end
end
