defmodule EctoPaginator.TestCase do
  use ExUnit.CaseTemplate

  using opts do
    quote do
      use ExUnit.Case, unquote(opts)
      import Ecto.Query
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoPaginator.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(EctoPaginator.Repo, {:shared, self()})
  end
end

EctoPaginator.Repo.start_link()
# Ecto.Adapters.SQL.Sandbox.mode(EctoPaginator.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
