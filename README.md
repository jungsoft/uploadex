# Uploadex

Uploadex is an Elixir library for handling uploads that integrates well with [Ecto](https://github.com/elixir-ecto/ecto), [Phoenix](https://github.com/phoenixframework/phoenix) and [Absinthe](https://github.com/absinthe-graphql/absinthe).

Documentation can be found at https://hexdocs.pm/uploadex.

## Installation

The package can be installed by adding `uploadex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:uploadex, "~> 2.0.0"}
  ]
end
```

## Usage

Follow these steps to use Uploadex:

### 1: Uploader

This library relies heavily on pattern matching for configuration, so the first step is to define your Uploader configuration module:

```elixir
defmodule MyApp.Uploader do
  @moduledoc false
  @behaviour Uploadex.Uploader

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
  def accepted_extensions(_any, _photo), do: :any
end
```

This example shows the configuration for the [Uploadex.FileStorage](https://hexdocs.pm/uploadex/Uploadex.FileStorage.html#content) and [Uploadex.S3Storage](https://hexdocs.pm/uploadex/Uploadex.S3Storage.html#content) implementations, but you are free to implement your own [Storage](https://hexdocs.pm/uploadex/Uploadex.Storage.html#content).

### 2: Config

Then, set your Upload module in your `config.exs`:

```elixir
config :uploadex,
  uploader: MyApp.Uploader,
  repo: MyApp.Repo
```

Note that the `Repo` is only necessary if using [Uploadex](https://hexdocs.pm/uploadex/Uploadex.html) context helper functions.

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

### 4: Enjoy!

Now, you can use the [Uploadex](https://hexdocs.pm/uploadex/Uploadex.html#content) functions to handle your records with their files:

```elixir
defmodule MyApp.Accounts do
  alias MyApp.Accounts.User
  alias MyApp.MyUploader

  def create_user(attrs) do
    %User{}
    |> User.create_changeset(attrs)
    |> Uploadex.create_with_file()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Uploadex.update_with_file(user)
  end

  def delete_user(%User{} = user) do
    user
    |> Ecto.Changeset.change()
    |> Uploadex.delete_with_file()
  end
end
```

You can also use the [Resolver](https://hexdocs.pm/uploadex/Uploadex.Resolver.html#content) module to integrate with Absinthe when exposing the files through a GraphQL API.

For more flexibility, you can use the [Files](https://hexdocs.pm/uploadex/Uploadex.Files.html#content) module directly, which provides some extra functionalities, such as `get_temporary_file`, useful when the files are not publicly available.

## Motivation

Even though there already exists a library for uploading files that integrates with ecto (https://github.com/stavro/arc_ecto), this library was created because:

* arc_ecto does not support upload of binary files
* Uploadex makes it easier to deal with records that contain files without having to manage those files manually on every operation
* Using uploadex, the changeset operations have no side-effects and no special casting is needed
* Uploadex offers more flexibility by allowing to define different storage configurations for each struct in the application
