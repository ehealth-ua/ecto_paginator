import Config

config :ecto_paginator, ecto_repos: [EctoPaginator.Repo]

config :ecto_paginator, EctoPaginator.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "ecto_paginator_test",
  username: System.get_env("ECTO_PAGINATOR_DB_USER") || System.get_env("USER")

config :logger, :console, level: :error
