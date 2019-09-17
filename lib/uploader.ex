defmodule Uploadex.Uploader do
  @moduledoc """
  Behaviour of an Uploader Definition.
  """

  @type record :: any()
  @type file :: map() | String.t()

  @callback get_files(record) :: file | [file]
  @callback default_opts(module :: atom()) :: opts :: Keyword.t()
  @callback storage(record) :: {module :: atom(), opts :: Keyword.t()}
end
