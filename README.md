# Uploadex

Uploadex is an Elixir library for handling uploads using [Ecto](https://github.com/elixir-ecto/ecto) and [Arc](https://github.com/stavro/arc).

Documentation can be found at https://hexdocs.pm/uploadex.

## Installation

The package can be installed by adding `uploadex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:uploadex, "~> 0.1.0"}
  ]
end
```

## Usage

This library is built on top of [Arc](https://github.com/stavro/arc), so you can configure it normally.
To use the default configuration, storing to the disk, no configuration is needed.

Then, define your uploader:

```elixir
defmodule MyApp.MyUploader do
  use Uploadex.Definition,
    repo: MyApp.Repo

  ## Functions required for Uploadex.Definition

  def base_directory do
    Path.join(:code.priv_dir(:my_app), "static/")
  end

  def get_files(%MyApp.User{photo: photo}), do: photo

  # For this example, we assume company has_many :photos, and each photo has a file field.
  # For this to work properly, we will need cast_assoc :photos when inserting/updating a company.
  def get_files(%MyApp.Company{} = company) do
    company
    |> MyApp.Repo.preload(:photos)
    |> Map.get(:photos)
    |> Enum.map(& &1.file)
  end

  ## We can also define the functions for Arc.Definition here

  def storage_dir(_version, {_file, %User{id: user_id}}) do
    Path.join(base_directory(), "/uploads/users/\#{user_id}")
  end

  def storage_dir(_version, {_file, %Company{id: id}}) do
    Path.join(base_directory(), "/uploads/companies/\#{id}")
  end
end
```

In your schema, use the Ecto Type [Uploadex.Upload](https://hexdocs.pm/uploadex/Uploadex.Upload.html):

```elixir
schema "users" do
  field :name, :string
  field :photo, Uploadex.Upload
end

# No special cast is needed, and casting does not have any side effects.
def create_changeset(%User{} = user, attrs) do
  user
  |> cast(attrs, [:name, :photo])
end
```

Now, you can use the [Uploadex](https://hexdocs.pm/uploadex/Uploadex.html) functions to handle your records with their files:

```elixir
defmodule MyApp.Accounts do
  alias MyApp.Accounts.User
  alias MyApp.MyUploader

  def create_user(attrs) do
    %User{}
    |> User.create_changeset(attrs)
    |> Uploadex.create_with_file(MyUploader)
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Uploadex.update_with_file(user, MyUploader)
  end

  def delete_user(%User{} = user) do
    user
    |> Ecto.Changeset.change()
    |> Uploadex.delete_with_file(MyUploader)
  end
end
```

For more flexibility, you can use the [Files](https://hexdocs.pm/uploadex/Uploadex.Files.html#content) module directly.

## Motivation

Even though there already exists a library to integrate Arc with Ecto (https://github.com/stavro/arc_ecto), this library was created because:

* arc_ecto does not support upload of binary files
* Uploadex makes it easier to deal with records that contain files without having to manage those files manually on every operation
* Using uploadex, the changeset operations have no side-effects and special casting is needed
