defmodule VideoCallWeb.HomeLive.Index do
  use VideoCallWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <div>This is the homepage</div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
