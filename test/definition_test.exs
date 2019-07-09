defmodule DefinitionTest do
  use ExUnit.Case
  doctest Uploadex

  describe "do_get_files/0" do
    defmodule Definition do
      use Uploadex.Definition, repo: :test

      def get_files(any), do: any
      def base_directory, do: :test
    end

    test "transforms an element into a list" do
      assert Definition.do_get_files(1) == [1]
    end

    test "transforms nil into an empty list" do
      assert Definition.do_get_files(nil) == []
    end

    test "does not transform a list without nil values" do
      assert Definition.do_get_files([1, 2, 3]) == [1, 2, 3]
    end

    test "transforms a list into an list without nil values" do
      assert Definition.do_get_files([1, 2, nil, 3]) == [1, 2, 3]
    end
  end

end
