import Mix.Config

config :uploadex,
  uploader: TestUploader,
  repo: Repo

config :task_after, global_name: TaskAfter
