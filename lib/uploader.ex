defmodule Uploadex.Uploader do
  @moduledoc """
  Behaviour of an Uploader.

  ## Example

      defmodule MyApp.Uploader do
        @moduledoc false
        @behaviour Uploadex.Uploader

        alias MyAppWeb.Endpoint

        @impl true
        def get_fields(%User{}), do: :photo
        def get_fields(%Company{}), do: [:photo]

        @impl true
        def default_opts(Uploadex.FileStorage), do: [base_path: :code.priv_dir(:my_app), base_url: Endpoint.url()]
        def default_opts(Uploadex.S3Storage), do: [bucket: "my_bucket", region: "sa-east-1", upload_opts: [acl: :public_read]]

        @impl true
        def storage(%User{id: id}, :photo), do: {Uploadex.FileStorage, directory: "/uploads/users/\#{id}"}
        def storage(%Company{}, :photo), do: {Uploadex.S3Storage, directory: "/thumbnails"}

        # Optional:
        @impl true
        def accepted_extensions(%User{}, _field), do: ~w(.jpg .png)
        def accepted_extensions(_any, _any), do: :any
      end

  """

  @type record :: any()
  @type record_field :: atom()
  @type file :: atom()

  @callback get_fields(record) :: file | [file]
  @callback default_opts(module :: atom()) :: opts :: Keyword.t
  @callback storage(record, record_field) :: {module :: atom(), opts :: Keyword.t}
  @callback accepted_extensions(record, record_field) :: [String.t] | :any

  @optional_callbacks accepted_extensions: 2
end
