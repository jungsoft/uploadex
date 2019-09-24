defmodule ValidationTest do
  use ExUnit.Case

  alias Uploadex.Validation

  describe "validate_extensions/2" do
    test "returns :ok when accepted extensions is :any" do
      assert :ok == Validation.validate_extensions(["anything"], :any)
    end

    test "handles both maps and strings" do
      assert :ok == Validation.validate_extensions([%{filename: "1.jpg"}, "2.jpg"], ".jpg")
      assert {:error, _} = Validation.validate_extensions([%{filename: "1.jpg"}, "2.png"], ".jpg")
      assert {:error, _} = Validation.validate_extensions([%{filename: "1.png"}, "2.jpg"], ".jpg")
    end

    test "handles uppercase extensions" do
      assert :ok == Validation.validate_extensions(["AAA.JPG"], ".jpg")
      assert :ok == Validation.validate_extensions(["AAA.JpG"], ".jpg")
    end
  end
end
