defmodule MyBlogWeb.HomeLive do
  alias MyBlog.Posts
  alias MyBlog.Blog.Post
  use MyBlogWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container">
      <h1>Welcome to Eds Blog</h1>
      <.button type="button" phx-click={show_modal("new-post-modal")}>New Post</.button>

      <div id="feed" phx-update="stream" class="flex flex-col gap-2">
        <div
          :for={{dom_id, post} <- @streams.posts}
          id={dom_id}
          class="w-1/2 mx-auto flex flex-col gap-2 p-4 border rounded"
        >
          <img src={post.image_path} />
          <p><%= post.user.email %></p>
          <p><%= post.title %></p>
        </div>
      </div>

      <.modal id="new-post-modal">
        <.simple_form for={@form} phx-change="validate" phx-submit="save-post">
          <.input field={@form[:title]} type="text" placeholder="Write Something!" required />
          <.live_file_input upload={@uploads.image} required />

          <.button type="submit">Post</.button>
        </.simple_form>
      </.modal>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    form =
      %Post{}
      |> Post.changeset(%{})
      |> to_form(as: "post")

    socket =
      socket
      |> assign(form: form)
      |> allow_upload(:image, accept: ~w(.jpg .jpeg), max_entries: 1)
      |> stream(:posts, Posts.list_posts())

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save-post", %{"post" => post_params}, socket) do
    %{current_user: user} = socket.assigns

    post_params
    |> Map.put("user_id", user.id)
    |> Map.put("image_path", List.first((socket))) # this is wrong but I don't know how to get the path
    |> Posts.save()

    {:noreply, socket}
  end

 #taken from docs. copies uploaded file to priv/static/uploads
 @impl Phoenix.LiveView
 def handle_event("save", _params, socket) do
   uploaded_files =
     consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
       dest = Path.join([:code.priv_dir(:my_blog), "static", "uploads", Path.basename(path)])
       # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
       File.cp!(path, dest)
       {:ok, ~p"/uploads/#{Path.basename(dest)}"}
     end)

   {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
 end

end
