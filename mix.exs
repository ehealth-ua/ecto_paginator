defmodule EctoPaginator.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_paginator,
      version: "0.2.0",
      elixir: "~> 1.8",
      description: "Paginate your Ecto queries with Scrivener",
      deps: deps(),
      aliases: aliases()
    ]
  end

  def aliases do
    [
      "db.reset": [
        "ecto.drop",
        "ecto.create",
        "ecto.migrate"
      ]
    ]
  end

  def applications(_) do [:scrivener, :logger] end

  def deps do
    [
      {:scrivener, "~> 2.4"},
      {:ecto, "~> 3.11.0"},
      {:ecto_sql, "~> 3.11.0", only: :test},
      {:postgrex, ">= 0.0.0", only: :test},
      {:ex_machina, "~> 2.3", only: [:dev, :test]}
    ]
  end
end
