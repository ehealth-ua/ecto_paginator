defmodule EctoPaginator.Migrations.CreateUsers do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string)
      add(:email, :string)
      add(:role, :string)

      timestamps()
    end
  end
end
