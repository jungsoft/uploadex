# Uploadex

Uploadex is an Elixir library for handling uploads that integrates well with [Ecto](https://github.com/elixir-ecto/ecto), [Phoenix](https://github.com/phoenixframework/phoenix) and [Absinthe](https://github.com/absinthe-graphql/absinthe).

Documentation can be found at https://hexdocs.pm/uploadex.

## Migrating from v2 to v3

1. In you uploader, change `@behaviour Uploadex.Uploader` to `use Uploadex`
1. Remove all `config :uploadex` from your configuration fiels
1. Change all direct functions calls from `Uploadex.Resolver`, `Uploadex.Files` and `Uploadex` to your Uploader module

## Installation

The package can be installed by adding `uploadex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:uploadex, "~> 3.0.0-rc.0"}
  ]
end
```

If you don't want to use the release candiate, go to the [latest stable version documentation](https://github.com/jungsoft/uploadex/tree/v2.0.3).

## Usage

Follow these steps to use Uploadex:

### 1: Uploader

This library relies heavily on pattern matching for configuration, so the first step is to define your Uploader configuration module:

```elixir
defmodule MyApp.Uploader do
  @moduledoc false

  use Uploadex,
    repo: MyApp.Repo # only necessary if using the functions from Uploadex.Context

  alias MyAppWeb.Endpoint

  @impl true
  def get_fields(%User{}), do: :photo
  def get_fields(%Company{}), do: [:photo]

  @impl true
  def default_opts(Uploadex.FileStorage), do: [base_path: Path.join(:code.priv_dir(:my_app), "static/"), base_url: Endpoint.url()]
  def default_opts(Uploadex.S3Storage), do: [bucket: "my_bucket", region: "sa-east-1", upload_opts: [acl: :public_read]]

  @impl true
  def storage(%User{id: id}, :photo), do: {Uploadex.FileStorage, directory: "/uploads/users/#{id}"}
  def storage(%Company{}, _field), do: {Uploadex.S3Storage, directory: "/thumbnails"}

  # Optional:
  @impl true
  def accepted_extensions(%User{}, :photo), do: ~w(.jpg .png)
  def accepted_extensions(_any, _field), do: :any
end
```

This example shows the configuration for the [Uploadex.FileStorage](https://hexdocs.pm/uploadex/Uploadex.FileStorage.html#content) and [Uploadex.S3Storage](https://hexdocs.pm/uploadex/Uploadex.S3Storage.html#content) implementations, but you are free to implement your own [Storage](https://hexdocs.pm/uploadex/Uploadex.Storage.html#content).

*Note: To avoid too much metaprogramming magic, the `use` in this module is very simple and, in fact, optional. If you wish to do so, you can just define the `@behaviour Uploadex.Uploader` instead of the `use` and then call all lower level modules directly, passing your Uploader module as argument. The `use` makes life much easier, though!*

### 2: Schema

In your schema, use the Ecto Type [Uploadex.Upload](https://hexdocs.pm/uploadex/Uploadex.Upload.html#content):

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

### 3: Enjoy!

Now, you can use your defined Uploader to handle your records with their files!

The `use Uploadex` line in your Uploader module will import 3 groups of functions:

#### Context

  The highest level functions are context helpers (see [Context]([Resolver](https://hexdocs.pm/uploadex/Uploadex.Context.html#content)) for more documentation), which will allow you to easily create, update and delete your records with associated files:

  ```elixir
  defmodule MyApp.Accounts do
    alias MyApp.Accounts.User
    alias MyApp.MyUploader

    def create_user(attrs) do
      %User{}
      |> User.create_changeset(attrs)
      |> MyUploader.create_with_file()
    end

    def update_user(%User{} = user, attrs) do
      user
      |> User.update_changeset(attrs)
      |> MyUploader.update_with_file(user)
    end

    def delete_user(%User{} = user) do
      MyUploader.delete_with_file(user)
    end
  end
  ```

#### Resolver

  There are also functions to help you easily fetch the files in Absinthe schemas:

  ```elixir
  object :user do
    field :photo_url, :string, resolve: MyUploader.get_file_url(:photo)
  end

  object :user do
    field :photos, list_of(:string), resolve: MyUploader.get_files_url(:photos)
  end
  ```

  See [Resolver](https://hexdocs.pm/uploadex/Uploadex.Resolver.html#content) for more documentation.

#### Files

If you need more flexibility, you can use the lower-level functions defined in [Files](https://hexdocs.pm/uploadex/Uploadex.Files.html#content), which provide some extra functionalities, such as `get_temporary_file`, useful when the files are not publicly available.

Some examples:

```elixir
{:ok, %User{}} = MyUploader.store_files(user)
{:ok, %User{}} = MyUploader.delete_files(user)
{:ok, %User{}} = MyUploader.delete_previous_files(user, user_after_change)
{:ok, files} = MyUploader.get_files_url(user, :photos)
```

## Motivation

Even though there already exists a library for uploading files that integrates with ecto (https://github.com/stavro/arc_ecto), this library was created because:

* arc_ecto does not support upload of binary files
* Uploadex makes it easier to deal with records that contain files without having to manage those files manually on every operation
* Using uploadex, the changeset operations have no side-effects and no special casting is needed
* Uploadex offers more flexibility by allowing to define different storage configurations for each struct (or even each field in a struct) in the application
* Uploadex does not rely on global configuration, which makes it easier to work in umbrella applications
