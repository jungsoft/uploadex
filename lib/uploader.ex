defmodule Uploadex.Uploader do
  @moduledoc """
  Behaviour of an Uploader.

  ## Example

      defmodule MyApp.Uploader do
        @moduledoc false
        @behaviour Uploadex.Uploader

        alias MyAppWeb.Endpoint

        @impl true
        def get_files(%User{photo: photo}), do: photo
        def get_files(%Company{photo: photo}), do: photo

        @impl true
        def default_opts(Uploadex.FileStorage), do: [base_path: :code.priv_dir(:my_app), base_url: Endpoint.url()]
        def default_opts(Uploadex.S3Storage), do: [bucket: "my_bucket", region: "sa-east-1", upload_opts: [acl: :public_read]]

        @impl true
        def storage(%User{id: id} = user), do: {Uploadex.FileStorage, directory: "/uploads/users/\#{id}"}
        def storage(%Company{} = company), do: {Uploadex.S3Storage, directory: "/thumbnails"}

        # Optional:
        @impl true
        def accepted_extensions(%User{}), do: ~w(.jpg .png)
        def accepted_extensions(_any), do: :any
      end

  """

  @type record :: any()
  @type file :: map() | String.t

  @callback get_files(record) :: file | [file]
  @callback default_opts(module :: atom()) :: opts :: Keyword.t
  @callback storage(record) :: {module :: atom(), opts :: Keyword.t}
  @callback accepted_extensions(record) :: list(String.t)

  @optional_callbacks accepted_extensions: 1
end
