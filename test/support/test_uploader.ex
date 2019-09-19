defmodule TestUploader do
  @moduledoc false
  @behaviour Uploadex.Uploader

  @impl true
  def get_files(%User{files: files}) do
    files
  end

  @impl true
  def default_opts(Uploadex.TestStorage), do: [a: 1, b: 2]

  @impl true
  def storage(%User{}) do
    {Uploadex.TestStorage, [directory: "test/dir"]}
  end
end
