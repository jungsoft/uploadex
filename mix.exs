defmodule Uploadex.MixProject do
  use Mix.Project

  def project do
    [
      app: :uploadex,
      version: "3.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Uploadex",
      description: "Elixir library for handling uploads with Ecto, Phoenix and Absinthe",
      source_url: "https://github.com/jungsoft/uploadex",
      package: package(),
      docs: docs(),
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix, :ex_aws, :ex_aws_s3],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      ],
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
        "GitHub" => "https://github.com/jungsoft/uploadex",
        "Docs" => "https://hexdocs.pm/uploadex/"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      # Ecto
      {:ecto, ">= 3.1.7"},
      # For AWS
      {:ex_aws, "~> 2.0 and >= 2.1.6", optional: true},
      {:ex_aws_s3, "~> 2.0", optional: true},
      {:poison, ">= 3.0.0", optional: true},
      {:hackney, ">= 1.9.0", optional: true},
      {:sweet_xml, "~> 0.6", optional: true},
      # Runtime checks and doc
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
    ]
  end
end
