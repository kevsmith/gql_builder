defmodule GqlBuilder.MixProject do
  use Mix.Project

  @source_url "https://github.com/kevsmith/gql_builder"
  @version "0.1.1"

  def project do
    [
      app: :gql_builder,
      version: @version,
      elixir: "~> 1.17.0",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        ci: :test
      ],
      consolidate_protocols: Mix.env() not in [:dev, :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.3", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.34.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      ci: ["lint", "test", "dialyzer"],
      lint: [
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo --strict"
      ]
    ]
  end

  defp package do
    [
      description: "Principled construction of GraphQL queries & mutations",
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: @version,
      formatters: ["html"]
    ]
  end
end
