defmodule MyBlog.Posts do
  import Ecto.Query, warn: false

  alias MyBlog.Repo
  alias MyBlog.Blog.Post

  #refactor?
  def list_posts do
    query =
      from p in Post,
        select: p,
        order_by: [desc: :inserted_at],
        preload: [:user]

    Repo.all(query)
  end

  def save(post_params) do
    %Post{}
    |> Post.changeset(post_params)
    |> Repo.insert_or_update()
  end
end
