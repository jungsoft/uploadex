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
        def default_opts(Uploadex.S3Storage), do: [bucket: "my_bucket", region: base_url: "sa-east-1", upload_opts: [acl: :public_read]]

        @impl true
        def storage(%User{} = user), do: {Uploadex.FileStorage, directory: storage_dir(user)}
        def storage(%Company{} = company), do: {Uploadex.S3Storage, directory: storage_dir(company)}

        def storage_dir(%User{id: user_id}), do: "/uploads/users/\#{user_id}"
        def storage_dir(%Company{}), do: "/thumbnails"
      end
  """

  @type record :: any()
  @type file :: map() | String.t()

  @callback get_files(record) :: file | [file]
  @callback default_opts(module :: atom()) :: opts :: Keyword.t()
  @callback storage(record) :: {module :: atom(), opts :: Keyword.t()}
end
