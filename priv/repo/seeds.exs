{:ok, _collection} =
  Foundation.Collections.create_collection(%{
    name: "Posts",
    description: "All the posts",
    fields: [
      %{name: "Title", description: "The title of the post", type: :string},
      %{name: "Content", description: "The content of the post", type: :string},
      %{name: "Published", description: "Check if the post is published", type: :boolean}
    ]
  })
