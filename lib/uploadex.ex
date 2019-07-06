defmodule Uploadex do
  @moduledoc """
  Context Helper functions for handling files.
  """

  alias Ecto.Multi
  alias Uploadex.Files

  def create_with_file(changeset, uploader) do
    repo = uploader.repo

    Multi.new()
    |> Multi.run(:insert, fn _repo, _ -> repo.insert(changeset) end)
    |> Multi.run(:store_files, fn _repo, %{insert: record} -> Files.store_files(record, uploader) end)
    |> repo.transaction()
    |> convert_result()
  end

  def update_with_file(changeset, previous_record, uploader) do
    repo = uploader.repo

    Multi.new()
    |> Multi.run(:update, fn _repo, _ -> repo.update(changeset) end)
    |> Multi.run(:store_files, fn _repo, %{update: record} -> Files.store_files(record, uploader) end)
    |> Multi.run(:delete_file, fn _repo, %{update: record} -> Files.delete_previous_files(record, previous_record, uploader) end)
    |> repo.transaction()
    |> convert_result()
  end

  def update_with_file(changeset, uploader) do
    repo = uploader.repo

    Multi.new()
    |> Multi.run(:update, fn _repo, _ -> repo.update(changeset) end)
    |> Multi.run(:store_files, fn _repo, %{update: record} -> Files.store_files(record, uploader) end)
    |> repo.transaction()
    |> convert_result()
  end

  def delete_with_file(record, uploader) do
    repo = uploader.repo

    case repo.delete(record) do
      {:ok, record} -> Files.delete_files(record, uploader)
      {:error, error} -> {:error, error}
    end
  end

  defp convert_result({:error, _, msg, _}), do: {:error, msg}
  defp convert_result({:ok, %{insert: record}}), do: {:ok, record}
  defp convert_result({:ok, %{update: record}}), do: {:ok, record}
end
