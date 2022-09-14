# Uploadex

Uploadex is an Elixir library for handling uploads that integrates well with [Ecto](https://github.com/elixir-ecto/ecto), [Phoenix](https://github.com/phoenixframework/phoenix) and [Absinthe](https://github.com/absinthe-graphql/absinthe).

Documentation can be found at https://hexdocs.pm/uploadex.

## Migrating from v2 to v3

1. In you uploader, change `@behaviour Uploadex.Uploader` to `use Uploadex`
1. Remove all `config :uploadex` from your configuration files
1. Change all direct functions calls from `Uploadex.Resolver`, `Uploadex.Files` and `Uploadex` to your Uploader module

## Installation

The package can be installed by adding `uploadex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:uploadex, "~> 3.0.0-rc.1"},
    # S3 dependencies(required for S3 storage only)
    {:ex_aws, "~> 2.1"},
    {:ex_aws_s3, "~> 2.0.2"},
    {:sweet_xml, "~> 0.6"},
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
  def get_fields(%Company{}), do: [:photo, :logo]

  @impl true
  def default_opts(Uploadex.FileStorage), do: [base_path: Path.join(:code.priv_dir(:my_app), "static/"), base_url: Endpoint.url()]
  def default_opts(Uploadex.S3Storage), do: [bucket: "my_bucket", region: "sa-east-1", upload_opts: [acl: :public_read]]

  @impl true
  def storage(%User{id: id}, :photo), do: {Uploadex.FileStorage, directory: "/uploads/users/#{id}"}
  def storage(%Company{id: id}, :photo), do: {Uploadex.S3Storage, directory: "/thumbnails/#{id}"}
  def storage(%Company{}, :logo), do: {Uploadex.S3Storage, directory: "/logos"}

  # Optional:
  @impl true
  def accepted_extensions(%User{}, :photo), do: ~w(.jpg .png)
  def accepted_extensions(_any, _field), do: :any
end
```

This example shows the configuration for the [Uploadex.FileStorage](https://hexdocs.pm/uploadex/Uploadex.FileStorage.html#content) and [Uploadex.S3Storage](https://hexdocs.pm/uploadex/Uploadex.S3Storage.html#content) implementations, but you are free to implement your own [Storage](https://hexdocs.pm/uploadex/Uploadex.Storage.html#content).

*Note: To avoid too much metaprogramming magic, the `use` in this module is very simple and, in fact, optional. If you wish to do so, you can just define the `@behaviour Uploadex.Uploader` instead of the `use` and then call all lower level modules directly, passing your Uploader module as argument. The `use` makes life much easier, though!*

### 2: Ecto Migration

A string field is required in the database to save the file reference.
The example below shows what would be needed to have a field to upload.

```elixir
defmodule MyApp.Repo.Migrations.AddPhotoToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :photo, :string
    end
  end
end
```

### 3: Schema

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

### 4: Configuration

Depending on which features you are using, you may need extra configurations:

#### Temporary Files

If you are using `get_temporary_file` or `get_temporary_files`, you need to configure [task_after](https://github.com/OvermindDL1/task_after):

```elixir
config :task_after, global_name: TaskAfter
```

#### S3 Configuration

If you are using the S3 adapter, add this to your configuration file. For more information access the [ex_aws_s3 documentation](https://github.com/ex-aws/ex_aws_s3):

```elixir
config :ex_aws, :s3,
  access_key_id: "key",
  secret_access_key: "secret",
  region: "us-east-1",
  host: "localhost",
  port: "9000",
  scheme: "http://"

config :my_project, :uploads,
  bucket: "uploads",
  region: "us-east-1"
```

### 5: Enjoy!

Now, you can use your defined Uploader to handle your records with their files!

The `use Uploadex` line in your Uploader module will import 3 groups of functions:

#### Context

  The highest level functions are context helpers (see [Context](https://hexdocs.pm/uploadex/3.0.0-rc.1/Uploadex.Context.html) for more documentation), which will allow you to easily create, update and delete your records with associated files:

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

## Testing

For knowing how to test with Uploadex, check the hexdocs of the [Testing](https://hexdocs.pm/uploadex/3.0.0-rc.1/Uploadex.Testing.html#content) module.

## Motivation

Even though there already exists a library for uploading files that integrates with ecto (https://github.com/stavro/arc_ecto), this library was created because:

* arc_ecto does not support upload of binary files
* Uploadex makes it easier to deal with records that contain files without having to manage those files manually on every operation
* Using uploadex, the changeset operations have no side-effects and no special casting is needed
* Uploadex offers more flexibility by allowing to define different storage configurations for each struct (or even each field in a struct) in the application
* Uploadex does not rely on global configuration, which makes it easier to work in umbrella applications
