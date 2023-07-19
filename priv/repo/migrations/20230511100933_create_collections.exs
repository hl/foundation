defmodule Foundation.Repo.Migrations.CreateCollections do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :name, :string
      add :description, :text
      add :fields, :map

      timestamps()
    end
  end
end
