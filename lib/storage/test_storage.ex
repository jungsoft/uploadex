defmodule Uploadex.TestStorage do
  @moduledoc """
  Storage for tests.

  See files_test.exs for examples on how to use this.
  """

  use Agent

  @behaviour Uploadex.Storage

  def start_link(initial_value \\ %{stored: [], deleted: [], opts: []}) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get_stored, do: Agent.get(__MODULE__, & &1.stored)

  def get_deleted, do: Agent.get(__MODULE__, & &1.deleted)

  def get_opts, do: Agent.get(__MODULE__, & &1.opts)

  def clear_stored, do: Agent.update(__MODULE__, fn state -> Map.put(state, :stored, []) end)

  @impl true
  def store(file, opts) do
    Agent.update(__MODULE__, fn state -> Map.update!(state, :stored, & &1 ++ [file]) end)
    Agent.update(__MODULE__, fn state -> Map.put(state, :opts, opts) end)
    :ok
  end

  @impl true
  def delete(file, opts) do
    Agent.update(__MODULE__, fn state -> Map.update!(state, :deleted, & &1 ++ [file]) end)
    Agent.update(__MODULE__, fn state -> Map.put(state, :opts, opts) end)
    :ok
  end

  @impl true
  def get_url(%{filename: filename}, _opts), do: {:ok, filename}
  def get_url(filename, _opts) when is_binary(filename), do: {:ok, filename}

  @impl true
  def get_temporary_file(%{filename: filename}, _path, _opts), do: filename
  def get_temporary_file(filename, _path, _opts) when is_binary(filename), do: filename
end
