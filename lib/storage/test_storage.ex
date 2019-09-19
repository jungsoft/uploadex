defmodule Uploadex.TestStorage do
  @moduledoc """
  Test storage.
  """

  use Agent

  @behaviour Uploadex.Storage

  def start_link(initial_value \\ %{stored: [], deleted: [], opts: []}) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get_stored, do: Agent.get(__MODULE__, & &1.stored)

  def get_deleted, do: Agent.get(__MODULE__, & &1.deleted)

  def get_opts, do: Agent.get(__MODULE__, & &1.opts)

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
  def get_url(%{filename: filename}, _opts \\ []) do
    filename
  end
end
