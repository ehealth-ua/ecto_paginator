defmodule EctoPaginator.Comment do
  @moduledoc false

  use Ecto.Schema

  schema "comments" do
    field(:text, :string)
    belongs_to(:article, EctoPaginator.Article)
    timestamps()
  end
end
