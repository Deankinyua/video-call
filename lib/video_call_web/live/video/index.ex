defmodule VideoCallWeb.VideoLive.Index do
  use VideoCallWeb, :live_view

  alias VideoCall.Accounts
  alias VideoCall.Calls
  alias VideoCall.WebrtcServer
  alias VideoCallWeb.ContactComponent
  alias VideoCallWeb.VideoComponents

  @larger_video_classes "w-full h-[72vh] max-w-[30rem] mx-auto rounded-lg overflow-hidden md:h-[80vh]"
  @smaller_video_classes "w-[9rem] max-w-[20rem] h-[28vh] z-30 absolute bottom-[9vh] right-[1rem] rounded-lg overflow-hidden sm:h-[22vh] sm:w-[40%] lg:w-[46%] sm:bottom-[12vh]"

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div
      id="video-parent"
      class="h-screen relative bg-black overflow-y-hidden"
      phx-hook="RtcConnection"
    >
      <div
        id="contacts"
        class="z-[2000] w-full h-screen px-2 contacts-shadow absolute hidden bg-[#1E1F24] text-[#E6E8EC] overflow-y-scroll sm:w-[22rem] sm:h-[50vh] sm:my-4 sm:rounded-xl sm:top-4 sm:right-4"
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
            <div :for={contact <- @contacts}>
              <.live_component
                username={contact.username}
                id={"contact-#{contact.id}"}
                module={ContactComponent}
              />
            </div>
          </div>
        </section>
      </div>

      <div class="py-10 px-4">
        <div id="videos" class="relative">
          <VideoComponents.call_notification
            show?={@show_incoming_call_notification}
            caller={@peer_2}
          />
          <VideoComponents.local_video class={@local_video_class} />
          <VideoComponents.remote_video class={@remote_video_class} />
          <VideoComponents.controls />
        </div>
      </div>

      <VideoComponents.call_declined_notification
        show?={@show_call_declined_notification}
        callee={@peer_2}
      />
      <VideoComponents.call_termination_notification
        show?={@show_call_termination_message}
        message={"#{@call_terminator} ended the call"}
      />
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    contacts = Accounts.list_users()

    if connected?(socket), do: Calls.subscribe(socket.assigns.current_user.username)

    {:ok,
     socket
     |> assign(:call_terminator, "")
     |> assign(:contacts, contacts)
     |> assign(
       :local_video_class,
       @larger_video_classes
     )
     |> assign(:peer_2, "")
     |> assign(
       :remote_video_class,
       @smaller_video_classes
     )
     |> assign(:show_call_declined_notification, false)
     |> assign(:show_call_termination_message, false)
     |> assign(:show_incoming_call_notification, false),
     temporary_assigns: [
       local_video_class: "",
       remote_video_class: ""
     ]}
  end

  @impl Phoenix.LiveView
  def handle_event("new_offer", %{"offer" => offer}, %{assigns: %{current_user: user}} = socket) do
    offer_object = %{
      offerer: user.username,
      offer: offer,
      offerer_ice_candidates: [],
      answerer: nil,
      answer: nil,
      answerer_ice_candidates: []
    }

    :ok = WebrtcServer.store_offer(offer_object)

    {:noreply, socket}
  end

  def handle_event(
        "accept_call",
        _params,
        %{assigns: %{peer_2: caller, current_user: user}} = socket
      ) do
    answerer = user.username
    offer_obj = WebrtcServer.update_offer(caller, answerer)
    Calls.notify_remote_peer_of_call_acceptance(caller, answerer)

    {:noreply,
     socket
     |> assign(:local_video_class, @smaller_video_classes)
     |> assign(:remote_video_class, @larger_video_classes)
     |> assign(:show_incoming_call_notification, false)
     |> push_event("answer", %{offer_obj: offer_obj})}
  end

  def handle_event(
        "decline_call",
        _params,
        %{assigns: %{peer_2: caller, current_user: user}} = socket
      ) do
    Calls.send_decline_call_notification(caller, user.username)

    {:noreply,
     socket
     |> assign(:peer_2, nil)
     |> assign(:show_incoming_call_notification, false)}
  end

  def handle_event(
        "send_ice_candidate_to_signalling_server",
        %{"did_i_offer" => from_offerer?, "ice_candidate" => candidate},
        %{assigns: %{current_user: user}} = socket
      ) do
    ice_user_id = user.username

    if from_offerer?,
      do: WebrtcServer.add_offerer_candidate(ice_user_id, candidate),
      else: WebrtcServer.add_answerer_candidate(ice_user_id, candidate)

    {:noreply, socket}
  end

  def handle_event(
        "add_offerer_ice_candidates_to_answerer",
        %{"offer_obj_id" => offer_obj_id},
        socket
      ) do
    offerer_ice_candidates = WebrtcServer.get_candidates(offer_obj_id, :offerer_ice_candidates)

    {:noreply,
     push_event(socket, "offerer_ice_candidates", %{candidates: offerer_ice_candidates})}
  end

  def handle_event(
        "clear_offer_object",
        _params,
        socket
      ) do
    offer_id = socket.assigns.current_user.username
    WebrtcServer.clear_offer_object(offer_id)

    {:noreply, socket}
  end

  def handle_event(
        "end_call",
        _params,
        socket
      ) do
    call_terminator = socket.assigns.current_user.username
    peer_2 = socket.assigns.peer_2

    if peer_2, do: Calls.notify_remote_peer_of_call_termination(peer_2, call_terminator)

    {:noreply,
     socket
     |> assign(:local_video_class, @larger_video_classes)
     |> assign(:peer_2, nil)
     |> assign(:remote_video_class, @smaller_video_classes)
     |> push_event("end_call", %{})}
  end

  def handle_event(
        "set_remote_description_of_offerer",
        %{"answer" => answer, "offerer" => offerer},
        socket
      ) do
    Calls.send_answer_to_offerer(offerer, answer)

    {:noreply, socket}
  end

  def handle_event("animation-finished", %{"target" => "call-termination-notification"}, socket),
    do: {:noreply, assign(socket, :show_call_termination_message, false)}

  def handle_event("animation-finished", _params, socket),
    do: {:noreply, assign(socket, :show_call_declined_notification, false)}

  @impl Phoenix.LiveView
  def handle_info(
        {:new_candidate, candidate},
        socket
      ),
      do:
        {:noreply,
         push_event(socket, "add_ice_candidate_from_other_peer", %{candidate: candidate})}

  def handle_info(
        {:answer_to_offer, answer},
        socket
      ),
      do: {:noreply, push_event(socket, "add_answer", %{answer: answer})}

  # call initialization, notify recipient and receive call
  def handle_info(
        {:notify_recipient_of_incoming_call, recipient},
        %{assigns: %{current_user: user}} = socket
      ) do
    Calls.call(recipient, user.username)

    {:noreply, push_event(socket, "create_offer", %{})}
  end

  def handle_info(
        {:incoming_call, caller},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:peer_2, caller)
     |> assign(:show_incoming_call_notification, true)}
  end

  # positive scenarios, call accepted
  def handle_info(
        {:call_accepted_by_other_peer, call_acceptor},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:local_video_class, @smaller_video_classes)
     |> assign(:peer_2, call_acceptor)
     |> assign(:remote_video_class, @larger_video_classes)}
  end

  # negative scenarios, call declined or call terminated
  def handle_info(
        {:call_declined, callee_username},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:peer_2, callee_username)
     |> assign(:show_call_declined_notification, true)}
  end

  def handle_info(
        {:call_terminated_by_other_peer, call_terminator},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:call_terminator, call_terminator)
     |> assign(:local_video_class, @larger_video_classes)
     |> assign(:remote_video_class, @smaller_video_classes)
     |> assign(:show_call_termination_message, true)
     |> push_event("end_call", %{})}
  end
end
