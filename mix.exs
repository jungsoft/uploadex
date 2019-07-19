defmodule Uploadex.MixProject do
  use Mix.Project

  def project do
    [
      app: :uploadex,
      version: "0.1.2",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Uploadex",
      source_url: "https://github.com/gabrielpra1/uploadex",
      description: "Elixir library for handling uploads using Ecto and Arc",
      package: package(),
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/gabrielpra1/uploadex",
        "Docs" => "https://hexdocs.pm/uploadex/"
      }
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.1.7"},
      {:arc, "~> 0.11.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
    ]
  end
end
