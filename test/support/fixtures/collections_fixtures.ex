defmodule Foundation.CollectionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Foundation.Collections` context.
  """

  @doc """
  Generate a collection.
  """
  def collection_fixture(attrs \\ %{}) do
    {:ok, collection} =
      attrs
      |> Enum.into(%{
        description: "some description",
        fields: %{},
        name: "some name"
      })
      |> Foundation.Collections.create_collection()

    collection
  end
end
