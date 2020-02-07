defmodule UploadTypeTest do
  use ExUnit.Case
  alias Uploadex.Upload

  @path "my/path/example.jpg"

  describe "cast/1" do
    test "for Plug.Upload" do
      upload = %{filename: "filename.jpg", path: "my/path/example", content_type: "image/jpeg"}
      assert {:ok, %{filename: filename, path: path}} = Upload.cast(upload)

      assert upload.path == path
      refute upload.filename == filename
      assert String.contains?(filename, ".jpg")
    end

    test "for base64 binary" do
      binary_example = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQAB"
      upload = %{filename: "filename.jpg", binary: binary_example}
      assert {:ok, %{filename: filename, binary: binary, content_type: "image/jpeg"}} = Upload.cast(upload)

      assert Base.decode64!("/9j/4AAQSkZJRgABAQAAAQAB") === binary
      refute upload.filename == filename
      assert String.contains?(filename, ".jpg")
    end

    test "for already processed binary" do
      processed_binary = Base.decode64!("/9j/4AAQSkZJRgABAQAAAQAB")
      upload = %{filename: "filename.jpg", binary: processed_binary}
      assert {:error, "Invalid base64 format"} = Upload.cast(upload)
    end

    test "for string" do
      assert {:ok, @path} == Upload.cast(@path)
    end

    test "for invalid type" do
      assert :error == Upload.cast(:invalid_input)
    end
  end

  describe "dump/1" do
    test "stores filename" do
      assert {:ok, @path} == Upload.dump(@path)
      assert {:ok, @path} == Upload.dump(%{filename: @path})
    end
  end

  describe "load/1" do
    test "loads filename" do
      assert {:ok, @path} == Upload.load(@path)
    end
  end

  describe "equal?/2" do
    test "returns true when filename is the same" do
      assert Upload.equal?(@path, @path)
      assert Upload.equal?(%{filename: @path}, @path)
      assert Upload.equal?(%{filename: @path}, %{filename: @path})
    end

    test "returns false when filename is not the same" do
      refute Upload.equal?(@path, @path <> "123")
      refute Upload.equal?(%{filename: @path}, @path <> "123")
      refute Upload.equal?(%{filename: @path}, %{filename: @path <> "123"})
      refute Upload.equal?(nil, @path)
    end
  end
end
