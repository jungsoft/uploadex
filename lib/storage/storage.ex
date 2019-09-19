defmodule Uploadex.Storage do
  @moduledoc """
  Behaviour for a Storage implementation.
  """

  @type record :: any()
  @type file :: map() | String.t()
  @type opts :: Keyword.t()

  @doc """
  Stores the file
  """
  @callback store(file, opts) :: :ok | {:error, any()}

  @doc """
  Deletes the file
  """
  @callback delete(file, opts) :: :ok | {:error, any()}

  @doc """
  Returns the file's URL
  """
  @callback get_url(file, opts) :: String.t()
end
