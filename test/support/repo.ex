defmodule EctoPaginator.Repo do
  @moduledoc false

  @paginator_options [page_size: 5, max_page_size: 10]

  use Ecto.Repo, otp_app: :ecto_paginator, adapter: Ecto.Adapters.Postgres
  use Scrivener, @paginator_options

  def paginator_options(options \\ []) do
    Scrivener.Config.new(__MODULE__, @paginator_options, options)
  end
end
