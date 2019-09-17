defmodule Uploadex.TestStorage do
  @moduledoc """
  Test storage.
  """

  use Agent

  @behaviour Uploadex.Storage

  def start_link(initial_value \\ %{stored: [], deleted: []}) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get_stored do
    Agent.get(__MODULE__, & &1.stored)
  end

  def get_deleted do
    Agent.get(__MODULE__, & &1.deleted)
  end

  def increment do
    Agent.update(__MODULE__, &(&1 + 1))
  end

  @impl true
  def store(file, _opts \\ []) do
    Agent.update(__MODULE__, fn state -> Map.update!(state, :stored, & &1 ++ [file]) end)
    :ok
  end

  @impl true
  def delete(file, _opts \\ []) do
    Agent.update(__MODULE__, fn state -> Map.update!(state, :deleted, & &1 ++ [file]) end)
    :ok
  end

  @impl true
  def get_url(%{filename: filename}, _opts \\ []) do
    filename
  end
end
