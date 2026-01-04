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
      class="z-[1000] w-[60%] flex flex-col gap-2 items-center mt-2 absolute top-0 left-[20%] mx-auto rounded-lg text-[#FFFFFF]"
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
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white" class="size-6">
              <g transform="rotate(135 12 12)">
                <path
                  fill-rule="evenodd"
                  d="M1.5 4.5a3 3 0 0 1 3-3h1.372c.86 0 1.61.586 1.819 1.42l1.105 4.423a1.875 1.875 0 0 1-.694 1.955l-1.293.97c-.135.101-.164.249-.126.352a11.285 11.285 0 0 0 6.697 6.697c.103.038.25.009.352-.126l.97-1.293a1.875 1.875 0 0 1 1.955-.694l4.423 1.105c.834.209 1.42.959 1.42 1.82V19.5a3 3 0 0 1-3 3h-2.25C8.552 22.5 1.5 15.448 1.5 6.75V4.5Z"
                  clip-rule="evenodd"
                />
              </g>
            </svg>
          </button>
          <div>Decline</div>
        </section>
        <section class="flex flex-col gap-2 items-center">
          <button
            class="w-14 h-14 rounded-full bg-[#34C759] flex items-center justify-center"
            phx-click={JS.push("answer_call")}
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

  attr :show?, :boolean, required: true
  attr :callee, :string, required: true

  @spec call_declined_notification(assigns()) :: rendered()
  def call_declined_notification(assigns) do
    ~H"""
    <div
      :if={@show?}
      class="text-[#ffffff] rounded-xl w-[20rem] flex gap-3 py-2 px-3 bg-[#1E1F24] absolute top-[2rem] right-4 md:top-4 md:animate-pulse"
    >
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
      <section class="flex-1 flex flex-col gap-2">
        <p>{@callee} declined your call.</p>
        <section class="flex justify-between">
          <p class="text-[#9AA0B8]">Your call was declined.</p>
          <div class="bg-[#1E6FD9] px-4 rounded text-sm flex items-center">OK</div>
        </section>
      </section>
    </div>
    """
  end

  @spec close_contacts_button(assigns()) :: rendered()
  def close_contacts_button(assigns) do
    ~H"""
    <div>
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
    </div>
    """
  end
end
