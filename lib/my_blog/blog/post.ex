defmodule MyBlog.Blog.Post do
  alias Hex.API.User
  use Ecto.Schema
  import Ecto.Changeset

  alias MyBlog.Accounts.User

  schema "blog_posts" do
    field :title, :string
    field :views, :integer, default: 0
    field :image_path, :string
    #changed association so we get full user struct back from db
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :views, :image_path, :user_id])
    |> validate_required([:title, :views, :image_path, :user_id])
  end
end
