defmodule VideoCallWeb.ContactComponent do
  @moduledoc false

  use VideoCallWeb, :live_component

  alias VideoCallWeb.VideoComponents

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="group flex items-center justify-between p-3 rounded-xl transition-all duration-200 hover:bg-white/[0.03] active:bg-white/[0.05] border border-transparent hover:border-white/5">
      <section class="flex gap-3 items-center">
        <div class="relative shrink-0">
          <div class="w-12 h-12 rounded-full overflow-hidden object-cover ring-2 ring-transparent group-hover:ring-zinc-700 transition-all">
            <VideoComponents.default_avatar fill="#000000" />
          </div>

          <span class="absolute bottom-0 right-0 block h-3 w-3 rounded-full bg-green-500 ring-2 ring-zinc-900">
          </span>
        </div>

        <div>
          <div class="text-[15px] font-medium text-zinc-200 group-hover:text-white transition-colors">
            {@username}
          </div>
          <div class="text-xs text-zinc-500">Available</div>
        </div>
      </section>

      <button
        class="w-10 h-10 rounded-full bg-emerald-500 text-white flex items-center justify-center shadow-lg shadow-emerald-500/20 opacity-90 sm:opacity-0 group-hover:opacity-100 transition-all transform hover:scale-110 active:scale-95"
        title={"Call #{@username}"}
        phx-target={@myself}
        phx-click={
          JS.hide(to: "#contacts", transition: "ease-in-out duration-300") |> JS.push("call")
        }
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-5">
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
