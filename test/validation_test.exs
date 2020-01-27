defmodule ValidationTest do
  use ExUnit.Case

  alias Uploadex.Validation

  describe "validate_extensions/2" do
    test "returns :ok when accepted extensions is :any" do
      assert :ok == Validation.validate_extensions(["anything"], :any)
    end

    test "should validate extensions" do
      assert :ok == Validation.validate_extensions([{%{filename: "1.jpg"}, :field, {}}], ".jpg")
      assert {:error, _msg} = Validation.validate_extensions([{%{filename: "2.png"}, :field, {}}], ".jpg")
    end

    test "handles uppercase extensions" do
      assert :ok == Validation.validate_extensions([{%{filename: "AAA.JPG"}, :field, {}}], ".jpg")
      assert :ok == Validation.validate_extensions([{%{filename: "AAA.JpG"}, :field, {}}], ".jpg")
    end
  end
end
