defmodule Foundation.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :description, :string
    field :name, :string

    embeds_many :fields, Foundation.Collections.CollectionField, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:name, :description])
    |> cast_embed(:fields)
    |> validate_required([:name])
  end
end
