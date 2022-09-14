defmodule Uploadex.Storage.TestStorageTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Uploadex.TestStorage

  describe "start_link/1" do
    test "with agent_name not set, should use the PID for the agent name" do
      TestStorage.start_link()

      assert :ok == TestStorage.store("file1.png", [])

      assert ["file1.png"] == TestStorage.get_stored()
      assert [agent_name: agent_name] = TestStorage.get_opts()
      assert to_string(agent_name) =~ "#PID<"
    end

    test "with agent_name set, should use the fixed agent name" do
      TestStorage.start_link(%{opts: [agent_name: :start_link_test_agent_name]})

      assert :ok == TestStorage.store("file1.png", agent_name: :start_link_test_agent_name)

      assert ["file1.png"] == TestStorage.get_stored(agent_name: :start_link_test_agent_name)

      assert [agent_name: :start_link_test_agent_name] ==
               TestStorage.get_opts(agent_name: :start_link_test_agent_name)
    end
  end

  describe "store/2" do
    test "adds the file to the state of the Agent" do
      TestStorage.start_link()

      TestStorage.store("file1.png", [])

      assert %{stored: ["file1.png"], deleted: [], opts: [_agent]} =
               Agent.get(get_pid_as_atom(), fn state -> state end)

      TestStorage.store("file2.png", [])

      assert %{stored: ["file1.png", "file2.png"], deleted: [], opts: [_agent]} =
               Agent.get(get_pid_as_atom(), fn state -> state end)
    end

    test "merges the opts to the state.opts of the Agent" do
      TestStorage.start_link()
      TestStorage.store("file1.png", another_opt: "another option")

      assert %{stored: ["file1.png"], deleted: [], opts: opts} =
               Agent.get(get_pid_as_atom(), fn state -> state end)

      assert Keyword.has_key?(opts, :agent_name)
      assert "another option" == Keyword.get(opts, :another_opt)
    end
  end

  describe "delete/2" do
    test "adds the file to the state of the Agent" do
      TestStorage.start_link()

      TestStorage.delete("file1.png", [])

      assert %{deleted: ["file1.png"], stored: [], opts: [_agent]} =
               Agent.get(get_pid_as_atom(), fn state -> state end)

      TestStorage.delete("file2.png", [])

      assert %{deleted: ["file1.png", "file2.png"], stored: [], opts: [_agent]} =
               Agent.get(get_pid_as_atom(), fn state -> state end)
    end

    test "merges the opts to the state.opts of the Agent" do
      TestStorage.start_link()
      TestStorage.delete("file1.png", another_opt: "another option")

      assert %{deleted: ["file1.png"], stored: [], opts: opts} =
               Agent.get(get_pid_as_atom(), fn state -> state end)

      assert Keyword.has_key?(opts, :agent_name)
      assert "another option" == Keyword.get(opts, :another_opt)
    end
  end

  describe "get_stored/1" do
    test "should return the stored files in the Agent" do
      TestStorage.start_link()

      Agent.update(get_pid_as_atom(), fn state -> Map.put(state, :stored, ["file.png"]) end)

      assert ["file.png"] == TestStorage.get_stored()
    end

    test "should return the stored files in the Agent with the name provided by the agent_name option" do
      TestStorage.start_link(%{opts: [agent_name: :get_stored_agent_name]})

      Agent.update(:get_stored_agent_name, fn state -> Map.put(state, :stored, ["file.png"]) end)

      assert ["file.png"] == TestStorage.get_stored(agent_name: :get_stored_agent_name)
    end
  end

  describe "get_deleted/1" do
    test "should return the deleted files in the Agent" do
      TestStorage.start_link()

      Agent.update(get_pid_as_atom(), fn state -> Map.put(state, :deleted, ["file.png"]) end)

      assert ["file.png"] == TestStorage.get_deleted()
    end

    test "should return the deleted files in the Agent with the name provided by the agent_name option" do
      TestStorage.start_link(%{opts: [agent_name: :get_deleted_agent_name]})

      Agent.update(:get_deleted_agent_name, fn state -> Map.put(state, :deleted, ["file.png"]) end)

      assert ["file.png"] == TestStorage.get_deleted(agent_name: :get_deleted_agent_name)
    end
  end

  describe "get_opts/1" do
    test "should return the opts files in the Agent" do
      TestStorage.start_link()

      Agent.update(get_pid_as_atom(), fn state -> Map.put(state, :opts, ["file.png"]) end)

      assert ["file.png"] == TestStorage.get_opts()
    end

    test "should return the opts files in the Agent with the name provided by the agent_name option" do
      TestStorage.start_link(%{opts: [agent_name: :get_opts_agent_name]})

      Agent.update(:get_opts_agent_name, fn state -> Map.put(state, :opts, option: "option") end)

      assert [option: "option"] == TestStorage.get_opts(agent_name: :get_opts_agent_name)
    end
  end

  describe "get_url/2" do
    test "should work with a map" do
      assert {:ok, "file.png"} == TestStorage.get_url(%{filename: "file.png"}, [])
    end

    test "should work with a binary" do
      assert {:ok, "file.png"} == TestStorage.get_url("file.png", [])
    end
  end

  describe "get_temporary_file/2" do
    test "should work with a map" do
      assert "file.png" == TestStorage.get_temporary_file(%{filename: "file.png"}, "", [])
    end

    test "should work with a binary" do
      assert "file.png" == TestStorage.get_temporary_file("file.png", "", [])
    end
  end

  defp get_pid_as_atom() do
    self() |> inspect() |> String.to_atom()
  end
end
