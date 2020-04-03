defmodule Uploadex.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :files, {:array, :string}

      timestamps()
    end
  end
end
