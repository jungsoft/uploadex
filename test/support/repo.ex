defmodule Uploadex.Repo do
  use Ecto.Repo,
    otp_app: :uploadex,
    adapter: Ecto.Adapters.Postgres
end
