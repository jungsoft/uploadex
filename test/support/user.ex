defmodule User do
  @moduledoc false

  defstruct files: [%{filename: "1.jpg"}, %{filename: "2.jpg"}]
end
