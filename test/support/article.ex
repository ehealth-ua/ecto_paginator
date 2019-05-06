defmodule EctoPaginator.Article do
  @moduledoc false

  use Ecto.Schema

  schema "articles" do
    field(:title, :string)
    belongs_to(:author, EctoPaginator.User)
    timestamps()
  end
end
