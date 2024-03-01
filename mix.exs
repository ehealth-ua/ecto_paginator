defmodule EctoPaginator.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_paginator,
      version: "0.2.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "Paginate your Ecto queries with Scrivener",
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp aliases do
    [
      "db.reset": [
        "ecto.drop",
        "ecto.create",
        "ecto.migrate"
      ]
    ]
  end

  def application do
    [
      applications: applications(Mix.env())
    ]
  end

  defp applications(:test), do: [:scrivener, :postgrex, :ecto, :logger, :telemetry]
  defp applications(_), do: [:scrivener, :logger]

  defp deps do
    [
      {:scrivener, "~> 2.4"},
      {:ecto, "~> 3.11.0"},
      {:ecto_sql, "~> 3.11.0", only: :test},
      {:postgrex, ">= 0.0.0", only: :test},
      {:ex_machina, "~> 2.3", only: [:dev, :test]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
