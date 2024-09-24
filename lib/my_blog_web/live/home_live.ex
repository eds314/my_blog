defmodule MyBlogWeb.HomeLive do
  alias MyBlog.Posts
  alias MyBlog.Blog.Post
  use MyBlogWeb, :live_view

  @impl Phoenix.LiveView
  def render(%{loading: true} = assigns) do
    ~H"""
    <h1>Loading...</h1>
    """
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
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

    <%!-- <table>
      <tbody id="feed" phx-update="stream">
        <tr :for={{dom_id, post} <- @streams.posts} id={dom_id}>
          <img src={post.image_path} />
          <td><%= post.user.email %></td>
          <td><%= post.title %></td>
        </tr>
      </tbody>
    </table> --%>

    <.modal id="new-post-modal">
      <.simple_form for={@form} phx-change="validate" phx-submit="save-post">
        <.input field={@form[:title]} type="text" placeholder="Write Something!" required />
        <.live_file_input upload={@uploads.image} required />

        <.button type="submit">Post</.button>
      </.simple_form>
    </.modal>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      form =
        %Post{}
        |> Post.changeset(%{})
        |> to_form(as: "post")

      socket =
        socket
        |> assign(form: form, loading: false)
        |> allow_upload(:image, accept: ~w(.jpg .jpeg), max_entries: 1)
        |> stream(:posts, Posts.list_posts(), at: 0)

      {:ok, socket}
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save-post", %{"post" => post_params}, socket) do
    %{current_user: user} = socket.assigns

    post_params
    |> Map.put("user_id", user.id)
    # this is wrong but I don't know how to get the path
    |> Map.put("image_path", List.first(consume_files(socket)))
    |> Posts.save()
    |> case do

      {:ok, _post} ->
        socket =
          socket
          |> put_flash(:info, "Post created successfully")
          |> push_navigate(to: ~p"/home")

        {:noreply, socket}

      {:error, changeset} ->
        IO.inspect(changeset)
        {:noreply, socket}
    end

    {:noreply, socket}
  end

  defp consume_files(socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
      dest = Path.join([:code.priv_dir(:my_blog), "static", "uploads", Path.basename(path)])
      File.cp!(path, dest)
      {:ok, ~p"/uploads/#{Path.basename(dest)}"}
    end)
  end
end
