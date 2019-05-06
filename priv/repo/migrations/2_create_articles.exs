defmodule EctoPaginator.Migrations.CreateArticles do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:articles) do
      add(:title, :string)
      add(:author_id, references(:users))
      timestamps()
    end
  end
end
