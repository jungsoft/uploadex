defmodule Uploadex.TestStorage do
  @moduledoc """
  Storage to be used for testing. It holds the files in memory (using a `Agent`).

  ## Configuring

  To configure your app to use the `Uploadex.TestStorage`, just add this storage to your `Uploadex` module,
  depending on the current environment:

      defmodule MyApp.Uploader do
        use Uploadex

        @impl true
        def get_fields(%User{}), do: :files

        @impl true
        def default_opts(Uploadex.FileStorage), do: [...]
        def default_opts(Uploadex.TestStorage), do: []

        @impl true
        def storage(%User{}, _field) do
          if test_environment?() do
            {Uploadex.TestStorage, []}
          else
            {Uploadex.FileStorage, [...]}
          end
        end

        @impl true
        def accepted_extensions(%User{}, _field), do: ~w(.jpg .png)

        defp test_environment?() do
          # This env must be set in your config files depending on the environment.
          Application.fetch_env!(:my_app, :environment) == :test
        end
      end

  ## Using

  In your `ExUnit` tests, add a `setup` block starting the storage:

      setup do
        Uploadex.TestStorage.start_link()
        :ok
      end

  Then, in the tests, you can use the `get_stored/1`, `get_deleted/1` and `get_opts`:

      test "some test with files" do
        assert ["document-1.pdf", "document-2.pdf"] == Uploadex.TestStorage.get_stored()
        assert ["deleted-document.pdf"] == Uploadex.TestStorage.get_deleted()
        assert [] == Uploadex.TestStorage.get_opts()
      end

  This module is just the base for testing, check `Uploadex.Testing` for a more convenient way to test uploads.
  """

  use Agent

  @behaviour Uploadex.Storage

  def start_link(initial_state \\ %{}) when is_map(initial_state) do
    agent_name = initial_state |> Map.get(:opts, []) |> get_agent_name()

    default_state = %{stored: [], deleted: [], opts: [agent_name: agent_name]}
    initial_state = Map.merge(default_state, Map.new(initial_state))

    Agent.start_link(fn -> initial_state end, name: agent_name)
  end

  def get_stored(opts \\ []) do
    opts
    |> get_agent_name()
    |> Agent.get(& &1.stored)
  end

  def get_deleted(opts \\ []) do
    opts
    |> get_agent_name()
    |> Agent.get(& &1.deleted)
  end

  def get_opts(opts \\ []) do
    opts
    |> get_agent_name()
    |> Agent.get(& &1.opts)
  end

  @impl true
  def store(file, opts) do
    opts
    |> get_agent_name()
    |> Agent.update(fn state ->
      state
      |> Map.update!(:stored, &(&1 ++ [file]))
      |> Map.update!(:opts, &Keyword.merge(&1, opts))
    end)

    :ok
  end

  @impl true
  def delete(file, opts) do
    opts
    |> get_agent_name()
    |> Agent.update(fn state ->
      state
      |> Map.update!(:deleted, &(&1 ++ [file]))
      |> Map.update!(:opts, &Keyword.merge(&1, opts))
    end)

    :ok
  end

  @impl true
  def get_url(%{filename: filename}, _opts), do: {:ok, filename}
  def get_url(filename, _opts) when is_binary(filename), do: {:ok, filename}

  @impl true
  def get_temporary_file(%{filename: filename}, _path, _opts), do: filename
  def get_temporary_file(filename, _path, _opts) when is_binary(filename), do: filename

  defp get_agent_name(opts) do
    current_pid_as_atom = self() |> inspect() |> String.to_atom()

    opts[:agent_name] || current_pid_as_atom
  end
end
