defmodule VideoCallWeb.VideoComponents do
  @moduledoc false

  use VideoCallWeb, :html

  @type assigns :: map()
  @type rendered :: Phoenix.LiveView.Rendered.t()

  attr :caller, :string, required: true
  attr :show?, :boolean, required: true

  @spec incoming_call_notification(assigns()) :: rendered()
  def incoming_call_notification(assigns) do
    ~H"""
    <div
      :if={@show?}
      class="w-[86%] max-w-[22rem] absolute top-6 left-[6%] z-50 animate-in fade-in slide-in-from-top-4 duration-300 left-medium"
      phx-mounted={JS.hide(to: "#contacts")}
    >
      <audio id="call-ringing-audio" src={~p"/sounds/ringtone.mp3"} autoplay loop phx-update="ignore">
      </audio>
      <div class="flex items-center gap-4 p-4 rounded-2xl bg-black/40 backdrop-blur-xl border border-white/10 shadow-2xl min-w-[320px]">
        <div class="relative shrink-0">
          <img
            src="/images/default_avatar.jpg"
            alt={@caller}
            class="w-14 h-14 rounded-full object-cover border-2 border-white/20"
          />
          <span class="absolute bottom-0 right-0 block h-3.5 w-3.5 rounded-full bg-green-500 ring-2 ring-black/40 animate-pulse">
          </span>
        </div>

        <div class="flex-1 flex flex-col">
          <h3 class="text-white font-semibold text-lg leading-tight truncate">{@caller}</h3>
          <p class="text-white/70 text-sm">Incoming video call...</p>

          <div class="flex gap-3 mt-3">
            <button
              phx-click={JS.push("decline_call")}
              class="flex-1 flex items-center justify-center gap-2 py-2 px-3 rounded-xl bg-red-500/20 hover:bg-red-500/30 text-red-100 transition-colors border border-red-500/20"
            >
              <svg class="w-4 h-4 fill-current" viewBox="0 0 24 24">
                <path
                  d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"
                  transform="rotate(135 12 12)"
                />
              </svg>
              <span class="text-xs font-medium">Decline</span>
            </button>

            <button
              phx-click={JS.push("accept_call")}
              class="flex-1 flex items-center justify-center gap-2 py-2 px-3 rounded-xl bg-green-500 hover:bg-green-600 text-white transition-all shadow-lg shadow-green-500/20 active:scale-95"
            >
              <div class="relative flex h-3 w-3">
                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-white opacity-75">
                </span>
                <svg class="relative w-4 h-4 fill-current" viewBox="0 0 24 24">
                  <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
                </svg>
              </div>
              <span class="text-xs font-medium">Answer</span>
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :callee, :string, required: true
  attr :show?, :boolean, required: true

  @spec outgoing_call_notification(assigns()) :: rendered()
  def outgoing_call_notification(assigns) do
    ~H"""
    <div
      :if={@show?}
      class="h-screen inset-0 bg-neutral-950 flex items-center justify-center p-6 z-[100]"
    >
      <div class="absolute inset-0 overflow-hidden">
        <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-red-500/10 rounded-full blur-[120px]">
        </div>
      </div>

      <section class="relative w-full max-w-md flex flex-col items-center justify-between h-[70vh] text-white">
        <div class="text-center space-y-2">
          <p class="text-sm font-medium tracking-widest uppercase text-white/50">Calling...</p>
          <h2 class="text-4xl font-light">{@callee}</h2>
        </div>

        <div class="relative flex items-center justify-center">
          <div class="absolute w-32 h-32 bg-white/10 rounded-full animate-ping"></div>
          <div class="absolute w-48 h-48 bg-white/5 rounded-full animate-[ping_3s_linear_infinite]">
          </div>

          <div class="relative w-32 h-32 md:w-40 md:h-40">
            <img
              src="/images/default_avatar.jpg"
              alt="recipient picture"
              class="w-full h-full rounded-full object-cover border-4 border-white/10 shadow-2xl"
            />
          </div>
        </div>

        <div class="flex flex-col items-center gap-6 w-full">
          <p class="text-white/40 text-sm animate-pulse">Waiting for answer</p>

          <button
            phx-click={JS.push("stop_calling")}
            class="group w-16 h-16 rounded-full flex items-center justify-center bg-red-500 hover:bg-red-600 transition-all duration-300 hover:scale-110 active:scale-90 shadow-xl shadow-red-500/20"
          >
            <svg class="w-8 h-8 fill-white rotate-[135deg]" viewBox="0 0 24 24">
              <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
            </svg>
          </button>

          <span class="text-xs text-white/20 font-medium tracking-tighter">END CALL</span>
        </div>
      </section>
    </div>
    """
  end

  attr :being_called?, :boolean, required: true
  attr :on_call?, :boolean, required: true

  @spec end_call_button(assigns()) :: rendered()
  def end_call_button(assigns) do
    ~H"""
    <button
      class="w-12 h-10 rounded-3xl flex items-center justify-center bg-[#FF3B30] disabled:opacity-50 disabled:cursor-not-allowed"
      phx-click={JS.push("end_call")}
      disabled={@being_called? || !@on_call?}
    >
      <svg
        fill="#ffffff"
        width="26px"
        height="26px"
        viewBox="0 0 56 56"
        xmlns="http://www.w3.org/2000/svg"
        stroke="#ffffff"
      >
        <g id="SVGRepo_bgCarrier-1" stroke-width="0"></g>
        <g id="SVGRepo_tracerCarrier-1" stroke-linecap="round" stroke-linejoin="round"></g>
        <g id="SVGRepo_iconCarrier-1">
          <path d="M 28.0235 17.6055 C 17.8751 17.6055 8.3361 19.7383 3.5783 24.4961 C 1.4454 26.6524 .3439 29.2539 .4845 32.3945 C .5782 34.2929 1.1642 35.9805 2.2657 37.0820 C 3.1095 37.9258 4.2345 38.3945 5.5704 38.1836 L 14.2657 36.7070 C 15.5783 36.4961 16.4923 36.0976 17.0783 35.4883 C 17.8517 34.7383 18.0861 33.6133 18.0861 32.1367 L 18.1095 29.7695 C 18.1095 29.3945 18.2735 29.1133 18.4845 28.8789 C 18.7188 28.5976 19.0704 28.4805 19.3283 28.4102 C 20.9220 28.0351 24.1798 27.6836 28.0235 27.6836 C 31.8908 27.6836 35.1251 27.9648 36.7188 28.4336 C 36.9532 28.5039 37.2814 28.6445 37.5392 28.8789 C 37.7735 29.1133 37.9142 29.3711 37.9142 29.7461 L 37.9376 32.1367 C 37.9610 33.6133 38.1954 34.7383 38.9454 35.4883 C 39.5548 36.0976 40.4688 36.4961 41.7814 36.7070 L 50.3593 38.1602 C 51.7422 38.3945 52.9144 37.9024 53.8283 37.0117 C 54.9299 35.9336 55.5390 34.2695 55.5861 32.3711 C 55.6561 29.2070 54.4609 26.6055 52.3518 24.4961 C 47.5705 19.7383 38.1720 17.6055 28.0235 17.6055 Z">
          </path>
        </g>
      </svg>
    </button>
    """
  end

  attr :being_called?, :boolean, required: true
  attr :on_call?, :boolean, required: true

  @spec show_contacts_button(assigns()) :: rendered()
  def show_contacts_button(assigns) do
    ~H"""
    <button
      phx-click={
        JS.toggle(to: "#contacts", in: "ease-out duration-300", out: "ease-in-out duration-300")
      }
      class="flex items-center justify-center w-12 h-10 rounded-3xl bg-[#3c3c3e] disabled:opacity-50 disabled:cursor-not-allowed"
      disabled={@being_called? || @on_call?}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="white"
        class="size-6"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z"
        />
      </svg>
    </button>
    """
  end

  @spec link_to_contacts(assigns()) :: rendered()
  def link_to_contacts(assigns) do
    ~H"""
    <div class="group w-max cursor-pointer ml-8 sm:ml-20" phx-click={JS.patch(~p"/contacts")}>
      <div class="relative flex items-center gap-3 px-6 py-[10px] rounded-full bg-zinc-950 border border-emerald-500/30 hover:border-emerald-400 transition-all duration-300 shadow-[0_0_15px_rgba(16,185,129,0.1)] hover:shadow-[0_0_25px_rgba(16,185,129,0.2)]">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-5 w-5 text-emerald-500 group-hover:scale-110 transition-transform"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          stroke-width="2.5"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
        </svg>

        <span class="text-sm font-semibold tracking-wide text-zinc-100 group-hover:text-white">
          Add Contacts
        </span>

        <div class="absolute inset-0 rounded-full bg-gradient-to-b from-white/5 to-transparent pointer-events-none">
        </div>
      </div>
    </div>
    """
  end

  @spec close_contacts_button(assigns()) :: rendered()
  def close_contacts_button(assigns) do
    ~H"""
    <div class="cursor-pointer">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-6">
        <path
          fill-rule="evenodd"
          d="M5.47 5.47a.75.75 0 0 1 1.06 0L12 10.94l5.47-5.47a.75.75 0 1 1 1.06 1.06L13.06 12l5.47 5.47a.75.75 0 1 1-1.06 1.06L12 13.06l-5.47 5.47a.75.75 0 0 1-1.06-1.06L10.94 12 5.47 6.53a.75.75 0 0 1 0-1.06Z"
          clip-rule="evenodd"
        />
      </svg>
    </div>
    """
  end

  attr :class, :string, required: true

  @spec local_video(assigns()) :: rendered()
  def local_video(assigns) do
    ~H"""
    <div class={@class}>
      <video class="w-full h-full object-cover" id="local-video" autoplay playsinline muted>
        This browser does not support video
      </video>
    </div>
    """
  end

  attr :class, :string, required: true

  @spec remote_video(assigns()) :: rendered()
  def remote_video(assigns) do
    ~H"""
    <div class={@class}>
      <video class="w-full h-full object-cover" id="remote-video" autoplay playsinline>
        This browser does not support video
      </video>
    </div>
    """
  end

  attr :being_called?, :boolean, required: true
  attr :on_call?, :boolean, required: true

  @spec controls(assigns()) :: rendered()
  def controls(assigns) do
    ~H"""
    <div class="w-max mx-auto px-4 mt-6 pt-4 flex gap-4 items-center">
      <.show_contacts_button being_called?={@being_called?} on_call?={@on_call?} />
      <.end_call_button being_called?={@being_called?} on_call?={@on_call?} />
      <.link_to_contacts />
    </div>
    """
  end

  @doc """
  A call will be declined if the callee specifically declines it or
  they are on another call
  """

  attr :message, :string, required: true
  attr :show?, :boolean, required: true

  @spec call_declined_notification(assigns()) :: rendered()
  def call_declined_notification(assigns) do
    ~H"""
    <div
      :if={@show?}
      id="declined-call-notification"
      class="fixed bottom-[16vh] left-1/2 -translate-x-1/2 z-[1100] animate-toast"
      phx-hook="Animation"
    >
      <div class="min-w-[14rem] flex items-center gap-3 p-3 rounded-xl bg-[#1E1F24] text-[#ffffff] shadow-lg shadow-black/30 border border-[#2a2b30]">
        <section class="size-7 bg-[#E53935] rounded-full flex items-center justify-center">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="size-5">
            <path
              d="M6 6L18 18M18 6L6 18"
              fill="none"
              stroke="#FFFFFF"
              stroke-width="2.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </section>

        <div class="text-sm font-medium">{@message}</div>
      </div>
    </div>
    """
  end

  @doc """
  A call will be terminated if one of the peers specifically terminates it,
  or they have a poor internet connection
  """

  attr :message, :string, required: true
  attr :show?, :boolean, required: true

  @spec call_termination_notification(assigns()) :: rendered()
  def call_termination_notification(assigns) do
    ~H"""
    <div
      :if={@show?}
      id="call-termination-notification"
      class="fixed bottom-[15vh] left-1/2 -translate-x-1/2 z-[1100] animate-toast"
      phx-hook="Animation"
    >
      <div class="min-w-[14rem] flex items-center gap-3 p-3 rounded-xl bg-[#1E1F24] text-[#ffffff] shadow-lg shadow-black/30 border border-[#2a2b30]">
        <span class="flex items-center justify-center w-6 h-6 rounded-full bg-[#1E6FD9]">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
            fill="currentColor"
            class="w-4 h-4"
          >
            <path
              fill-rule="evenodd"
              d="M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0Zm-7-4a1 1 0 1 1-2 0 1 1 0 0 1 2 0ZM9 9a.75.75 0 0 0 0 1.5h.253a.25.25 0 0 1 .244.304l-.459 2.066A1.75 1.75 0 0 0 10.747 15H11a.75.75 0 0 0 0-1.5h-.253a.25.25 0 0 1-.244-.304l.459-2.066A1.75 1.75 0 0 0 9.253 9H9Z"
              clip-rule="evenodd"
            />
          </svg>
        </span>
        <p class="text-sm font-medium">{@message}</p>
      </div>
    </div>
    """
  end
end
