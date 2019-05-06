defmodule EctoPaginator.Migrations.CreateComments do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:comments) do
      add(:text, :string)
      add(:article_id, references(:articles))
      timestamps()
    end
  end
end
