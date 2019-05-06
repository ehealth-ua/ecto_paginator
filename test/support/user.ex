defmodule EctoPaginator.User do
  @moduledoc false

  use Ecto.Schema

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:role, :string)
    timestamps()
  end
end
