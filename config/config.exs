import Mix.Config

config :task_after, global_name: TaskAfter

env_config = "#{Mix.env()}.exs"
if File.exists?(Path.join("config", env_config)), do: import_config(env_config)
