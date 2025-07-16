defmodule VideoCallWeb.VideoLive.Index do
  use VideoCallWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center">
      Welcome to our Video
    </div>
    """
  end
end
