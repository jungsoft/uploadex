{:ok, _pid} = Uploadex.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Uploadex.Repo, :manual)
ExUnit.start()
