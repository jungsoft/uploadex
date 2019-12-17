defmodule Uploadex.MixProject do
  use Mix.Project

  def project do
    [
      app: :uploadex,
      version: "1.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Uploadex",
      source_url: "https://github.com/gabrielpra1/uploadex",
      description: "Elixir library for handling uploads using Ecto and Arc",
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

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
      # Ecto
      {:ecto, ">= 3.1.7"},
      # For AWS
      {:ex_aws, "~> 2.0", optional: true},
      {:ex_aws_s3, "~> 2.0", optional: true},
      {:poison, ">= 3.0.0", optional: true},
      {:hackney, ">= 1.9.0", optional: true},
      {:sweet_xml, "~> 0.6", optional: true},
      # Runtime checks and doc
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      # Temporary files
      {:task_after, "~> 1.0.0"},
    ]
  end
end
