import Mix.Config

config :uploadex,
  uploader: TestUploader,
  repo: Repo

config :task_after, global_name: TaskAfter

config :ex_aws, :s3,
  access_key_id: "test",
  secret_access_key: "test"
