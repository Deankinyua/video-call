defmodule VideoCallWeb.ContactComponents do
  @moduledoc false

  use VideoCallWeb, :html

  @type assigns :: map()
  @type rendered :: Phoenix.LiveView.Rendered.t()

  @spec contact_component(assigns()) :: rendered()
  def contact_component(assigns) do
    ~H"""
    <div class="flex gap-4 mb-2 border border-red-400">
      <section>{@username}</section>
      <section>call</section>
      <section>answer</section>
    </div>
    """
  end
end
