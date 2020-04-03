defmodule User do
  @moduledoc false

  defstruct files: [%{filename: "1.jpg"}, %{filename: "2.jpg"}]
end


defmodule UserSchema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :files, {:array, Uploadex.Upload}

    timestamps()
  end

  @fields ~w(files)a

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
