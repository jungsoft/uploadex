defmodule TestUploader do
  @moduledoc false
  @behaviour Uploadex.Uploader

  @impl true
  def get_fields(%User{}), do: :files

  @impl true
  def default_opts(Uploadex.TestStorage), do: [a: 1, b: 2]

  @impl true
  def storage(%User{}, _field) do
    {Uploadex.TestStorage, [directory: "/test/dir/"]}
  end

  @impl true
  def accepted_extensions(%User{}, _field), do: ~w(.jpg .png)
end
