defmodule VideoCallWeb.VideoComponents do
  @moduledoc false

  use VideoCallWeb, :html

  @type assigns :: map()
  @type rendered :: Phoenix.LiveView.Rendered.t()

  attr :show?, :boolean, required: true
  attr :caller, :string, required: true

  @spec call_notification(assigns()) :: rendered()
  def call_notification(assigns) do
    ~H"""
    <div
      :if={@show?}
      class="z-[1000] w-[60%] flex flex-col gap-2 items-center mt-2 absolute top-[3rem] left-[20%] mx-auto rounded-lg text-[#FFFFFF]"
    >
      <div class="flex flex-col gap-2 items-center">
        <section>
          <img
            src="/images/default_avatar.jpg"
            alt={@caller}
            class="w-24 h-24 rounded-full object-cover"
          />
        </section>
        <section>{@caller}</section>
        <section>Incoming call...</section>
      </div>
      <div class="flex gap-28">
        <section class="flex flex-col gap-2 items-center">
          <button
            class="w-14 h-14 rounded-full bg-[#FF3B30] flex items-center justify-center"
            phx-click={JS.push("decline_call")}
          >
            <svg
              fill="#ffffff"
              width="26px"
              height="26px"
              viewBox="0 0 56 56"
              xmlns="http://www.w3.org/2000/svg"
              stroke="#ffffff"
            >
              <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
              <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
              <g id="SVGRepo_iconCarrier">
                <path d="M 28.0235 17.6055 C 17.8751 17.6055 8.3361 19.7383 3.5783 24.4961 C 1.4454 26.6524 .3439 29.2539 .4845 32.3945 C .5782 34.2929 1.1642 35.9805 2.2657 37.0820 C 3.1095 37.9258 4.2345 38.3945 5.5704 38.1836 L 14.2657 36.7070 C 15.5783 36.4961 16.4923 36.0976 17.0783 35.4883 C 17.8517 34.7383 18.0861 33.6133 18.0861 32.1367 L 18.1095 29.7695 C 18.1095 29.3945 18.2735 29.1133 18.4845 28.8789 C 18.7188 28.5976 19.0704 28.4805 19.3283 28.4102 C 20.9220 28.0351 24.1798 27.6836 28.0235 27.6836 C 31.8908 27.6836 35.1251 27.9648 36.7188 28.4336 C 36.9532 28.5039 37.2814 28.6445 37.5392 28.8789 C 37.7735 29.1133 37.9142 29.3711 37.9142 29.7461 L 37.9376 32.1367 C 37.9610 33.6133 38.1954 34.7383 38.9454 35.4883 C 39.5548 36.0976 40.4688 36.4961 41.7814 36.7070 L 50.3593 38.1602 C 51.7422 38.3945 52.9144 37.9024 53.8283 37.0117 C 54.9299 35.9336 55.5390 34.2695 55.5861 32.3711 C 55.6561 29.2070 54.4609 26.6055 52.3518 24.4961 C 47.5705 19.7383 38.1720 17.6055 28.0235 17.6055 Z">
                </path>
              </g>
            </svg>
          </button>
          <div>Decline</div>
        </section>
        <section class="flex flex-col gap-2 items-center">
          <button
            class="w-14 h-14 rounded-full bg-[#34C759] flex items-center justify-center"
            phx-click={JS.push("accept_call")}
          >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white" class="size-6">
              <path
                fill-rule="evenodd"
                d="M1.5 4.5a3 3 0 0 1 3-3h1.372c.86 0 1.61.586 1.819 1.42l1.105 4.423a1.875 1.875 0 0 1-.694 1.955l-1.293.97c-.135.101-.164.249-.126.352a11.285 11.285 0 0 0 6.697 6.697c.103.038.25.009.352-.126l.97-1.293a1.875 1.875 0 0 1 1.955-.694l4.423 1.105c.834.209 1.42.959 1.42 1.82V19.5a3 3 0 0 1-3 3h-2.25C8.552 22.5 1.5 15.448 1.5 6.75V4.5Z"
                clip-rule="evenodd"
              />
            </svg>
          </button>
          <div>Answer</div>
        </section>
      </div>
    </div>
    """
  end

  @spec end_call_button(assigns()) :: rendered()
  def end_call_button(assigns) do
    ~H"""
    <button
      class="w-12 h-10 rounded-3xl flex items-center justify-center bg-[#FF3B30]"
      phx-click={JS.push("end_call")}
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

  @spec show_contacts_button(assigns()) :: rendered()
  def show_contacts_button(assigns) do
    ~H"""
    <button
      phx-click={
        JS.toggle(to: "#contacts", in: "ease-out duration-300", out: "ease-in-out duration-300")
      }
      class="flex items-center justify-center w-12 h-10 rounded-3xl bg-[#3c3c3e]"
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

  @spec controls(assigns()) :: rendered()
  def controls(assigns) do
    ~H"""
    <div class="w-max mx-auto bg-[#1b1c1d] rounded-3xl px-4 mt-10 py-3 flex gap-4">
      <.show_contacts_button />
      <.end_call_button />
    </div>
    """
  end

  attr :show?, :boolean, required: true
  attr :callee, :string, required: true

  @spec call_declined_notification(assigns()) :: rendered()
  def call_declined_notification(assigns) do
    ~H"""
    <div
      :if={@show?}
      id="toast"
      class="fixed bottom-[16vh] left-1/2 -translate-x-1/2 z-[1100] animate-toast"
    >
      <div class="min-w-[14rem] flex items-center gap-3 px-2 py-3 rounded-xl bg-[#1E1F24] text-[#ffffff] shadow-lg shadow-black/30 border border-[#2a2b30]">
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

        <div class="text-sm font-medium">{@callee} declined your call.</div>
      </div>
    </div>
    """
  end

  attr :message, :string, required: true
  attr :show?, :boolean, required: true

  @spec toast(assigns()) :: rendered()
  def toast(assigns) do
    ~H"""
    <div
      :if={@show?}
      id="toast"
      class="fixed bottom-[15vh] left-1/2 -translate-x-1/2 z-[1100] animate-toast"
    >
      <div class="flex items-center gap-3 px-5 py-3 rounded-xl bg-[#1E1F24] text-[#ffffff] shadow-lg shadow-black/30 border border-[#2a2b30]">
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
