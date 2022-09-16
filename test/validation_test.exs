defmodule ValidationTest do
  use ExUnit.Case, async: true

  alias Uploadex.Validation

  describe "validate_extensions/2" do
    test "returns :ok when accepted extensions is :any" do
      assert :ok == Validation.validate_extensions(["anything"], :any)
    end

    test "should validate extensions" do
      assert :ok == Validation.validate_extensions([{%{filename: "1.jpg"}, :field, {}}], ".jpg")
      assert {:error, _msg} = Validation.validate_extensions([{%{filename: "2.png"}, :field, {}}], ".jpg")
    end

    test "should return errors messages with the filenames and valid extensions" do
      expected_message = ~s(Some files in ["2.png"] violate the accepted extensions: ".jpg")

      assert {:error, ^expected_message} = Validation.validate_extensions([{%{filename: "2.png"}, :field, {}}], ".jpg")
      assert {:error, ^expected_message} = Validation.validate_extensions([{"2.png", :field, {}}], ".jpg")
    end

    test "handles uppercase extensions" do
      assert :ok == Validation.validate_extensions([{%{filename: "AAA.JPG"}, :field, {}}], ".jpg")
      assert :ok == Validation.validate_extensions([{%{filename: "AAA.JpG"}, :field, {}}], ".jpg")
    end
  end
end
