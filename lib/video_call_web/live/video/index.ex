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
      <VideoComponents.call_notification show?={@show_call_notification} caller={@caller} />

      <div
        id="contacts"
        class="z-50 w-full h-screen px-2 contacts-shadow absolute hidden bg-[#1E1F24] text-[#E6E8EC] overflow-y-scroll sm:w-[22rem] sm:h-[50vh] sm:my-4 sm:rounded-xl sm:top-4 sm:right-4"
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
                contact={contact}
                id={"contact-#{contact.id}"}
                module={ContactComponent}
              />
            </div>
          </div>
        </section>
      </div>

      <div class="py-10 px-4">
        <div id="videos" class="relative">
          <VideoComponents.local_video class={@local_video_class} />
          <VideoComponents.remote_video class={@remote_video_class} />
          <VideoComponents.controls />
        </div>
      </div>

      <VideoComponents.call_declined_notification
        show?={@show_call_declined_notification}
        callee={@callee}
      />
      <VideoComponents.toast
        show={@show_call_ended_message}
        message={"#{@call_ender_name} ended the call"}
      />
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    contacts = Accounts.list_users()

    if connected?(socket), do: Calls.subscribe(socket.assigns.current_user.id)

    {:ok,
     socket
     |> assign(:call_ender_name, "")
     |> assign(:caller, "")
     |> assign(:callee, "")
     |> assign(:contacts, contacts)
     |> assign(
       :local_video_class,
       @larger_video_classes
     )
     |> assign(
       :remote_video_class,
       @smaller_video_classes
     )
     |> assign(:show_call_declined_notification, false)
     |> assign(:show_call_ended_message, false)
     |> assign(:show_call_notification, false),
     temporary_assigns: [local_video_class: "", remote_video_class: ""]}
  end

  @impl Phoenix.LiveView
  def handle_event("new_offer", %{"offer" => offer}, %{assigns: %{current_user: user}} = socket) do
    offer_object = %{
      offerer: user.id,
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
        "answer_call",
        _params,
        %{assigns: %{caller_id: caller_id, current_user: user}} = socket
      ) do
    answerer = user.id
    offer_obj = WebrtcServer.update_offer(caller_id, answerer)

    Calls.switch_caller_view(offer_obj.offerer, :remote_large)

    {:noreply,
     socket
     |> assign(:callee_id, nil)
     |> assign(:local_video_class, @smaller_video_classes)
     |> assign(:remote_video_class, @larger_video_classes)
     |> assign(:show_call_notification, false)
     |> push_event("answer", %{offer_obj: offer_obj})}
  end

  def handle_event(
        "decline_call",
        _params,
        %{assigns: %{caller_id: caller_id, current_user: user}} = socket
      ) do
    Calls.send_decline_call_notification(caller_id, user.username)

    {:noreply, assign(socket, :show_call_notification, false)}
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
    offer_id = socket.assigns.current_user.id
    WebrtcServer.clear_offer_object(offer_id)

    {:noreply, socket}
  end

  def handle_event(
        "end_call",
        _params,
        socket
      ) do
    caller = Map.get(socket.assigns, :caller_id)
    callee = Map.get(socket.assigns, :callee_id)

    if caller,
      do: Calls.switch_caller_view(caller, :local_large),
      else: Calls.switch_caller_view(callee, :local_large)

    {:noreply,
     socket
     |> assign(:local_video_class, @larger_video_classes)
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

  @impl Phoenix.LiveView
  def handle_info(
        {:notify_recipient, recipient_id},
        %{assigns: %{current_user: user}} = socket
      ) do
    Calls.call(recipient_id, user.username, user.id)

    {:noreply,
     socket
     |> assign(:callee_id, recipient_id)
     |> assign(:caller_id, nil)
     |> push_event("create_offer", %{})}
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

  def handle_info(
        {:call_declined, callee_username},
        socket
      ),
      do:
        {:noreply,
         socket
         |> assign(:callee, callee_username)
         |> assign(:show_call_declined_notification, true)}

  def handle_info(
        :switch_remote_stream_to_large,
        socket
      ) do
    {:noreply,
     socket
     |> assign(:local_video_class, @smaller_video_classes)
     |> assign(:remote_video_class, @larger_video_classes)}
  end

  def handle_info(
        :switch_local_stream_to_large,
        socket
      ) do
    caller = Map.get(socket.assigns, :caller_id)

    other_peer_username =
      if caller do
        # get caller
        peer_2 = Accounts.get_user!(caller)

        peer_2.username
      else
        callee = Map.get(socket.assigns, :callee_id)
        peer_2 = Accounts.get_user!(callee)

        peer_2.username
      end

    {:noreply,
     socket
     |> assign(:call_ender_name, other_peer_username)
     |> assign(:local_video_class, @larger_video_classes)
     |> assign(:remote_video_class, @smaller_video_classes)
     |> assign(:show_call_ended_message, true)
     |> push_event("end_call", %{})}
  end
end
