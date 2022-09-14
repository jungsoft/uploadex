defmodule S3StorageTest do
  use ExUnit.Case, async: true

  alias Uploadex.S3Storage

  @opts [bucket: "my-bucket", region: "sa-east-1", directory: "/thumbnails/"]

  describe "get_url/2" do
    test "accepts both a map with filename and the filename directly" do
      assert S3Storage.get_url(%{filename: "filename.jpg"}, @opts) == S3Storage.get_url("filename.jpg", @opts)
    end

    test "builds the URL correctly" do
      assert {:ok, link} = S3Storage.get_url("filename.jpg", @opts)
      assert String.starts_with?(link, "https://s3.amazonaws.com/my-bucket/thumbnails/filename.jpg?")
    end
  end
end
