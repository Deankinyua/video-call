defmodule VideoCallWeb.ContactComponent do
  @moduledoc false

  use VideoCallWeb, :live_component

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="bg-[#24262C] cursor-pointer rounded-xl mb-3 flex justify-between items-center p-2 hover:bg-[#2C2F36]">
      <section class="flex gap-4 items-center">
        <div class="shrink-0">
          <img
            src="/images/default_avatar.jpg"
            alt={@username}
            class="w-12 h-12 rounded-full object-cover"
          />
        </div>
        <div class="text-lg">{@username}</div>
      </section>
      <button
        class="w-11 h-11 rounded-full bg-[#2ED760] flex items-center justify-center"
        phx-target={@myself}
        phx-click={
          JS.hide(to: "#contacts", transition: "ease-in-out duration-300") |> JS.push("call")
        }
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white" class="size-5">
          <path
            fill-rule="evenodd"
            d="M1.5 4.5a3 3 0 0 1 3-3h1.372c.86 0 1.61.586 1.819 1.42l1.105 4.423a1.875 1.875 0 0 1-.694 1.955l-1.293.97c-.135.101-.164.249-.126.352a11.285 11.285 0 0 0 6.697 6.697c.103.038.25.009.352-.126l.97-1.293a1.875 1.875 0 0 1 1.955-.694l4.423 1.105c.834.209 1.42.959 1.42 1.82V19.5a3 3 0 0 1-3 3h-2.25C8.552 22.5 1.5 15.448 1.5 6.75V4.5Z"
            clip-rule="evenodd"
          />
        </svg>
      </button>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("call", _params, socket) do
    recipient = socket.assigns.username
    send(self(), {:notify_recipient_of_incoming_call, recipient})
    {:noreply, socket}
  end
end
