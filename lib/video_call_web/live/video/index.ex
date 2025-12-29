defmodule VideoCallWeb.VideoLive.Index do
  use VideoCallWeb, :live_view

  alias VideoCall.Accounts
  alias VideoCall.Calls
  alias VideoCall.WebrtcServer
  alias VideoCallWeb.ContactComponent
  alias VideoCallWeb.VideoComponents

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div
      id="video-parent"
      class="h-screen relative bg-black overflow-y-hidden"
      phx-hook="RtcConnection"
    >
      <VideoComponents.call_notification show?={@show_call_notification} caller={@caller} />

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

            <VideoComponents.close_contacts_button />
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
          <VideoComponents.local_video />
          <VideoComponents.remote_video />
        </div>
      </div>

      <VideoComponents.controls />
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

    {:noreply,
     socket
     |> assign(:show_call_notification, false)
     |> push_event("answer", %{offer_obj: offer_obj})}
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
