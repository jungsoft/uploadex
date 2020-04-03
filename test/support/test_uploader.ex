defmodule TestUploader do
  @moduledoc false
  use Uploadex,
    repo: Uploadex.Repo

  @impl true
  def get_fields(%User{}), do: :files
  def get_fields(%UserSchema{}), do: :files

  @impl true
  def default_opts(Uploadex.TestStorage), do: [a: 1, b: 2]

  @impl true
  def storage(%User{}, _field), do: {Uploadex.TestStorage, [directory: "/test/dir/"]}
  def storage(%UserSchema{}, _field), do: {Uploadex.TestStorage, [directory: "/test/dir/"]}

  @impl true
  def accepted_extensions(%User{}, _field), do: ~w(.jpg .png)
  def accepted_extensions(%UserSchema{}, _field), do: ~w(.jpg .png)
end
