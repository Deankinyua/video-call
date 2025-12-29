defmodule VideoCallWeb.VideoLive.Index do
  use VideoCallWeb, :live_view

  alias VideoCall.Accounts
  alias VideoCall.Calls
  alias VideoCall.WebrtcServer
  alias VideoCallWeb.ContactComponent

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div
      id="video-parent"
      class="h-screen relative bg-black overflow-y-hidden"
      phx-hook="RtcConnection"
    >
      <div
        :if={@show_call_notification}
        class="w-[60%] flex flex-col gap-6 items-center mt-10 rounded-lg"
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
              phx-click={JS.push("decline")}
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
              phx-click={JS.push("answer")}
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
      <div
        id="contacts"
        class="w-full h-screen px-2 contacts-shadow mx-auto absolute hidden bg-[#FFFFFF] z-50 sm:w-[22rem] sm:h-[50vh] sm:my-4 sm:border-[0.5px] sm:border-[#CBCBCB] sm:rounded-xl sm:top-4 sm:right-4"
      >
        <section class="w-[92%] mx-auto my-4 flex flex-col gap-4">
          <div
            class="flex justify-between items-center"
            phx-click={JS.hide(to: "#contacts", transition: "ease-in-out duration-300")}
          >
            <p class="roboto-semibold text-xl">Contacts</p>
            <section>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="currentColor"
                class="size-6"
              >
                <path
                  fill-rule="evenodd"
                  d="M5.47 5.47a.75.75 0 0 1 1.06 0L12 10.94l5.47-5.47a.75.75 0 1 1 1.06 1.06L13.06 12l5.47 5.47a.75.75 0 1 1-1.06 1.06L12 13.06l-5.47 5.47a.75.75 0 0 1-1.06-1.06L10.94 12 5.47 6.53a.75.75 0 0 1 0-1.06Z"
                  clip-rule="evenodd"
                />
              </svg>
            </section>
          </div>
          <div>
            <div
              :for={contact <- @contacts}
              class="first:rounded-t-lg last:rounded-b-lg last:border-b border-x border-t border-[#CBCBCB]"
            >
              <.live_component
                contact={contact}
                id={"contact-#{contact.id}"}
                module={ContactComponent}
              />
            </div>
          </div>
        </section>
      </div>

      <div class="h-[10rem] sm:h-[2rem]"></div>

      <div>
        <div id="videos" class="flex flex-col gap-2 relative border border-blue-400">
          <div>
            <video
              class="w-full h-[70vh] sm:h-[80vh] max-w-[30rem] mx-auto object-cover local-video"
              id="local-video"
              autoplay
              playsinline
              muted
            >
            </video>
          </div>
          <div>
            <video
              class="z-30 w-[10rem] h-[13rem] object-cover border border-red-400 absolute bottom-[-3rem] right-[2rem] sm:w-[16rem]  sm:bottom-[1rem] remote-video"
              id="remote-video"
              autoplay
              playsinline
            >
            </video>
          </div>
        </div>
      </div>

      <div class="absolute bottom-[3rem] left-[25%] bg-[#ffffff] rounded-lg px-4 py-2">
        <button phx-click={
          JS.toggle(to: "#contacts", in: "ease-out duration-300", out: "ease-in-out duration-300")
        }>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="black"
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
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    contacts = Accounts.list_users()

    if connected?(socket), do: Calls.subscribe(socket.assigns.current_user.id)

    {:ok,
     socket
     |> assign(:caller, "")
     |> assign(:contacts, contacts)
     |> assign(:show_call_notification, false)}
  end

  @impl Phoenix.LiveView
  def handle_event("new_offer", %{"offer" => offer}, %{assigns: %{current_user: user}} = socket) do
    offer_object = %{
      offerer: user.id,
      offer: offer,
      offererIceCandidates: [],
      answerer: nil,
      answer: nil,
      answererIceCandidates: []
    }

    :ok = WebrtcServer.store_offer(offer_object)

    {:noreply, socket}
  end

  def handle_event(
        "answer",
        _params,
        %{assigns: %{caller_id: caller_id, current_user: user}} = socket
      ) do
    answerer = user.id
    offer_obj = WebrtcServer.update_offer(caller_id, answerer)

    {:noreply, push_event(socket, "answer", %{offer_obj: offer_obj})}
  end

  def handle_event(
        "send_ice_candidates_to_signalling_server",
        %{"did_i_offer" => from_offerer?, "ice_candidate" => candidate},
        %{assigns: %{current_user: user}} = socket
      ) do
    ice_user_id = user.id

    if from_offerer?,
      do: WebrtcServer.add_offerer_candidate(ice_user_id, candidate),
      else: WebrtcServer.add_answerer_candidate(ice_user_id, candidate)

    {:noreply, socket}
  end

  def handle_event(
        "add_offerer_ice_candidates_to_answerer",
        %{"offerer" => offerer},
        socket
      ) do
    offerer_ice_candidates = WebrtcServer.get_candidates(offerer, :offererIceCandidates)

    {:noreply,
     push_event(socket, "offerer_ice_candidates", %{candidates: offerer_ice_candidates})}
  end

  def handle_event(
        "set_remote_description_of_offerer",
        %{"answer" => answer, "offerer" => offerer},
        socket
      ) do
    Calls.send_answer_to_offerer(offerer, answer)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info(
        {:notify_recipient, recipient_id},
        %{assigns: %{current_user: user}} = socket
      ) do
    Calls.call(recipient_id, user.username, user.id)
    {:noreply, push_event(socket, "create_offer", %{})}
  end

  def handle_info(
        {:new_call, caller_username, caller_id},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:caller, caller_username)
     |> assign(:caller_id, caller_id)
     |> assign(:show_call_notification, true)}
  end

  def handle_info(
        {:new_candidate, candidate},
        socket
      ),
      do:
        {:noreply,
         push_event(socket, "add_ice_candidates_from_other_peer", %{candidate: candidate})}

  def handle_info(
        {:answer_to_offer, answer},
        socket
      ),
      do: {:noreply, push_event(socket, "add_answer", %{answer: answer})}
end
