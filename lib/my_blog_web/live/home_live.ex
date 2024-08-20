defmodule MyBlogWeb.HomeLive do
  use MyBlogWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="container">
      <h1>Welcome to My Blog</h1>
    </div>
    """
  end
    def mount(_params, _session, socket) do
      {:ok, socket}
    end
  end
