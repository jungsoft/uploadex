defmodule S3StorageTest do
  use ExUnit.Case

  alias Uploadex.S3Storage

  @opts [bucket: "my-bucket", region: "sa-east-1", directory: "thumbnails"]

  describe "get_url/2" do
    test "accepts both a map with filename and the filename directly" do
      assert S3Storage.get_url(%{filename: "filename.jpg"}, @opts) == S3Storage.get_url("filename.jpg", @opts)
    end

    test "builds the URL correctly" do
      assert "https://my-bucket.s3-sa-east-1.amazonaws.com/thumbnails/filename.jpg" == S3Storage.get_url("filename.jpg", @opts)
    end
  end
end
