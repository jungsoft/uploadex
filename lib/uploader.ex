defmodule Uploadex.Uploader do
  @moduledoc """
  Behaviour of an Uploader Definition.
  """

  @type record :: any()
  @type file :: map() | String.t()

  @callback get_files(record) :: file | [file]
  @callback do_get_files(record) :: [String.t()]

  @callback base_directory() :: String.t()

  @callback repo :: any()

  @optional_callbacks repo: 0
end
