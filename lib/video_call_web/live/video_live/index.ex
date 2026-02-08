defmodule VideoCallWeb.VideoLive.Index do
  use VideoCallWeb, :live_view

  import VideoCallWeb.VideoLive.Components

  alias VideoCall.Calls
  alias VideoCall.Contacts
  alias VideoCall.SignallingSupervisor
  alias VideoCall.WebrtcServer
  alias VideoCallWeb.ContactComponent

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
      <section
        id="contacts"
        class="z-[2000] fixed inset-0 hidden w-full h-full overflow-y-scroll bg-zinc-900/95 backdrop-blur-xl text-zinc-100 shadow-2xl flex flex-col sm:w-96 sm:h-[600px] sm:top-6 sm:right-6 sm:absolute sm:inset-auto sm:rounded-2xl sm:border sm:border-white/10"
      >
        <header class="p-5 border-b border-white/5 flex justify-between items-center bg-zinc-900/50">
          <div>
            <h2 class="font-semibold text-xl tracking-tight">Contacts</h2>
            <p class="text-xs text-zinc-500">
              {@contacts_count} {if @contacts_count == 1, do: "contact", else: "contacts"}
            </p>
          </div>

          <button
            phx-click={
              JS.hide(
                to: "#contacts",
                transition: "transition-all ease-in-out duration-300 opacity-0 scale-95"
              )
            }
            class="p-2 hover:bg-white/10 rounded-full transition-colors"
          >
            <.close_contacts_button />
          </button>
        </header>

        <div class="flex-1 p-4">
          <div class="space-y-1">
            <div :for={contact <- @contacts}>
              <.live_component
                id={"contact-#{contact.id}"}
                module={ContactComponent}
                username={contact.contact_user.username}
              />
            </div>
          </div>
        </div>
      </section>

      <.outgoing_call_notification callee={@peer_2} show?={@show_outgoing_call_notification?} />

      <div class="py-10 px-4">
        <div id="videos" class="relative">
          <.incoming_call_notification caller={@peer_2} show?={@show_incoming_call_notification?} />
          <.local_video class={@local_video_class} />
          <.remote_video class={@remote_video_class} />
          <div class="mx-auto max-w-[30rem]">
            <.controls being_called?={@show_incoming_call_notification?} on_call?={@on_call?} />
          </div>
        </div>
      </div>

      <.call_declined_notification
        message={@call_declined_message}
        show?={@show_call_declined_notification?}
      />

      <.call_termination_notification
        message={@call_termination_message}
        show?={@show_call_termination_message?}
      />
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket), do: Calls.subscribe(socket.assigns.current_user.username)

    socket
    |> assign_call_state()
    |> assign_contacts()
    |> assign_video_layout()
  end

  @impl Phoenix.LiveView
  def handle_event("new_offer", %{"offer" => offer}, %{assigns: %{current_user: user}} = socket) do
    genserver = genserver_name(user.username)
    SignallingSupervisor.start_server(genserver)

    offer_object = %{
      offerer: user.username,
      offer: offer,
      offerer_ice_candidates: [],
      answerer: nil,
      answer: nil,
      answerer_ice_candidates: []
    }

    :ok = WebrtcServer.store_offer(genserver, offer_object)
    {:noreply, assign(socket, :genserver, genserver)}
  end

  def handle_event(
        "accept_call",
        _params,
        %{assigns: %{current_user: user, genserver: genserver, peer_2: caller}} = socket
      ) do
    answerer = user.username
    offer_obj = WebrtcServer.update_offer(genserver, answerer)
    Calls.notify_remote_peer_of_call_acceptance(caller, answerer)

    {:noreply,
     socket
     |> assign(:local_video_class, @smaller_video_classes)
     |> assign(:remote_video_class, @larger_video_classes)
     |> assign(:show_incoming_call_notification?, false)
     |> push_event("answer", %{offer_obj: offer_obj})}
  end

  def handle_event(
        "decline_call",
        _params,
        %{assigns: %{current_user: user, peer_2: caller}} = socket
      ) do
    Calls.send_decline_call_notification(caller, user.username)

    {:noreply,
     socket
     |> assign(:peer_2, nil)
     |> assign(:show_incoming_call_notification?, false)}
  end

  def handle_event(
        "send_ice_candidate_to_signalling_server",
        %{"did_i_offer" => from_offerer?, "ice_candidate" => candidate},
        %{assigns: %{genserver: genserver}} = socket
      ) do
    if from_offerer?,
      do: WebrtcServer.add_offerer_candidate(genserver, candidate),
      else: WebrtcServer.add_answerer_candidate(genserver, candidate)

    {:noreply, socket}
  end

  def handle_event(
        "add_offerer_ice_candidates_to_answerer",
        _params,
        %{assigns: %{genserver: genserver}} = socket
      ) do
    offerer_ice_candidates =
      WebrtcServer.get_candidates(genserver, :offerer_ice_candidates)

    {:noreply,
     push_event(socket, "offerer_ice_candidates", %{candidates: offerer_ice_candidates})}
  end

  def handle_event(
        "end_call",
        _params,
        %{assigns: %{current_user: user, genserver: genserver, peer_2: peer_2}} = socket
      ) do
    Calls.notify_remote_peer_of_call_termination(peer_2, user.username)
    SignallingSupervisor.stop_server(genserver)

    {:noreply,
     socket
     |> assign(:local_video_class, @larger_video_classes)
     |> assign(:on_call?, false)
     |> assign(:peer_2, nil)
     |> assign(:remote_video_class, @smaller_video_classes)
     |> push_event("end_call", %{})}
  end

  def handle_event(
        "stop_calling",
        _params,
        %{assigns: %{current_user: user, genserver: genserver, peer_2: peer_2}} = socket
      ) do
    Calls.send_missed_call_notification(peer_2, user.username)
    SignallingSupervisor.stop_server(genserver)

    {:noreply,
     socket
     |> assign(:peer_2, nil)
     |> assign(:show_outgoing_call_notification?, false)}
  end

  def handle_event(
        "set_remote_description_of_offerer",
        %{"answer" => answer, "offerer" => offerer},
        socket
      ) do
    Calls.send_answer_to_offerer(offerer, answer)

    {:noreply, socket}
  end

  def handle_event(
        "peer_connection_disconnected",
        _params,
        %{assigns: %{genserver: genserver, peer_2: peer_2}} = socket
      ) do
    SignallingSupervisor.stop_server(genserver)

    {:noreply,
     socket
     |> assign(:call_termination_message, "call was ended due #{peer_2}'s network issues")
     |> assign(:local_video_class, @larger_video_classes)
     |> assign(:on_call?, false)
     |> assign(:peer_2, nil)
     |> assign(:remote_video_class, @smaller_video_classes)
     |> assign(:show_call_termination_message?, true)
     |> push_event("end_call", %{})}
  end

  def handle_event(
        "peer_connection_connected",
        _params,
        socket
      ),
      do: {:noreply, assign(socket, :on_call?, true)}

  def handle_event("animation-finished", %{"target" => "call-termination-notification"}, socket),
    do: {:noreply, assign(socket, :show_call_termination_message?, false)}

  def handle_event("animation-finished", _params, socket),
    do: {:noreply, assign(socket, :show_call_declined_notification?, false)}

  @impl Phoenix.LiveView
  def handle_info(
        {:new_candidate, candidate},
        socket
      ) do
    {:noreply, push_event(socket, "add_ice_candidate_from_other_peer", %{candidate: candidate})}
  end

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

    {:noreply,
     socket
     |> assign(:peer_2, recipient)
     |> assign(:show_outgoing_call_notification?, true)
     |> push_event("create_offer", %{})}
  end

  def handle_info(
        {:incoming_call, caller},
        %{
          assigns: %{
            on_call?: on_call?,
            show_incoming_call_notification?: being_called?,
            show_outgoing_call_notification?: calling_someone?
          }
        } =
          socket
      ),
      do: handle_incoming_call(on_call?, being_called?, calling_someone?, caller, socket)

  # positive scenarios, call accepted
  def handle_info(
        {:call_accepted_by_other_peer, call_acceptor},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:local_video_class, @smaller_video_classes)
     |> assign(:peer_2, call_acceptor)
     |> assign(:remote_video_class, @larger_video_classes)
     |> assign(:show_outgoing_call_notification?, false)}
  end

  # negative scenarios, call declined or call terminated
  def handle_info({:call_declined, callee_username}, %{assigns: %{genserver: genserver}} = socket) do
    SignallingSupervisor.stop_server(genserver)

    {:noreply,
     socket
     |> assign(:call_declined_message, "#{callee_username} declined the call")
     |> assign(:peer_2, nil)
     |> assign(:show_call_declined_notification?, true)
     |> assign(:show_outgoing_call_notification?, false)}
  end

  def handle_info(
        {:call_terminated_by_other_peer, call_terminator},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:call_termination_message, "#{call_terminator} ended the call")
     |> assign(:local_video_class, @larger_video_classes)
     |> assign(:on_call?, false)
     |> assign(:peer_2, nil)
     |> assign(:remote_video_class, @smaller_video_classes)
     |> assign(:show_call_termination_message?, true)
     |> push_event("end_call", %{})}
  end

  def handle_info(
        {:missed_call, caller},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:call_termination_message, "#{caller} got tired of waiting")
     |> assign(:show_call_termination_message?, true)
     |> assign(:show_incoming_call_notification?, false)}
  end

  def handle_info(:line_busy, %{assigns: %{genserver: genserver, peer_2: peer_2}} = socket) do
    SignallingSupervisor.stop_server(genserver)

    {:noreply,
     socket
     |> assign(:call_declined_message, "#{peer_2} is on another call")
     |> assign(:peer_2, nil)
     |> assign(:show_call_declined_notification?, true)
     |> assign(:show_outgoing_call_notification?, false)}
  end

  defp assign_call_state(socket) do
    socket
    |> assign(:call_declined_message, "")
    |> assign(:call_termination_message, "")
    |> assign(:on_call?, false)
    |> assign(:peer_2, "")
    |> assign(:show_call_declined_notification?, false)
    |> assign(:show_call_termination_message?, false)
    |> assign(:show_incoming_call_notification?, false)
    |> assign(:show_outgoing_call_notification?, false)
  end

  defp assign_contacts(%{assigns: %{current_user: user}} = socket) do
    contacts = Contacts.list_contacts(%{user_id: user.id})

    socket
    |> assign(:contacts, contacts)
    |> assign(:contacts_count, Enum.count(contacts))
  end

  defp assign_video_layout(socket) do
    {:ok,
     socket
     |> assign(:local_video_class, @larger_video_classes)
     |> assign(:remote_video_class, @smaller_video_classes),
     temporary_assigns: [
       local_video_class: "",
       remote_video_class: ""
     ]}
  end

  defp handle_incoming_call(on_call?, being_called?, calling_someone?, caller, socket)
       when on_call? or being_called? or calling_someone? do
    Calls.send_line_busy_notification(caller)

    {:noreply, socket}
  end

  defp handle_incoming_call(_on_call?, _being_called?, _calling_someone?, caller, socket) do
    genserver = genserver_name(caller)

    {:noreply,
     socket
     |> assign(:genserver, genserver)
     |> assign(:peer_2, caller)
     |> assign(:show_incoming_call_notification?, true)}
  end

  defp genserver_name(caller), do: "#{caller}_server"
end
