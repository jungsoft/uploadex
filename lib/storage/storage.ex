defmodule Uploadex.Storage do
  @moduledoc """
  Behaviour for a Storage implementation.
  """

  @type record :: any()
  @type file :: map() | String.t()
  @type opts :: Keyword.t()

  @callback store(file, opts) :: :ok | {:error, any()}
  @callback delete(file, opts) :: :ok | {:error, any()}
  @callback get_url(file, opts) :: String.t()
end
