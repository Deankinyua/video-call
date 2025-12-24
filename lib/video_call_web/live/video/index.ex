defmodule VideoCallWeb.VideoLive.Index do
  use VideoCallWeb, :live_view

  alias VideoCall.Accounts
  alias VideoCall.Calls
  alias VideoCall.WebrtcServer
  alias VideoCallWeb.ContactComponent

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div id="video-parent" class="relative" phx-hook="RtcConnection">
      <div
        :if={@show_call_notification}
        class="w-[60%] flex flex-col gap-6 items-center mt-10 border border-red-400 rounded-lg"
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
      <div class="ml-4 mt-28 w-[60%] border border-red-400">
        <div id="videos" class="flex flex-col gap-4">
          <div>
            <video
              class="w-[30rem] h-[20rem]  local-video"
              id="local-video"
              autoplay
              playsinline
              muted
            >
            </video>
          </div>
          <div>
            <video class="w-[30rem] h-[20rem] remote-video" id="remote-video" autoplay playsinline>
            </video>
          </div>
        </div>
      </div>

      <div id="contacts" class="w-[24rem] absolute top-8 right-8">
        <div class="mb-2">Contacts</div>
        <div :for={contact <- @contacts}>
          <.live_component contact={contact} id={"contact-#{contact.id}"} module={ContactComponent} />
        </div>
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

    {:noreply, assign(socket, :current_offer, offer_object)}
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
    {:noreply, socket}
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
