defmodule Foundation.Collections.CollectionField do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :description, :string
    field :name, :string
    field :type, Ecto.Enum, values: [:string, :number, :boolean, :json]
    field :delete, :boolean, virtual: true

    timestamps()
  end

  @doc false
  def changeset(collection_field, %{"delete" => "true"}) do
    %{change(collection_field, delete: true) | action: :delete}
  end

  def changeset(collection_field, attrs) do
    collection_field
    |> cast(attrs, [:name, :description, :type])
    |> validate_required([:name, :type])
  end
end
