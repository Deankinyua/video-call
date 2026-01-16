defmodule VideoCallWeb.ContactLive.Index do
  use VideoCallWeb, :live_view

  import VideoCallWeb.ContactLive.Components

  alias VideoCall.Accounts
  alias VideoCall.Contacts

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="h-screen relative overflow-hidden bg-black text-zinc-100 p-6 sm:p-12">
      <button phx-click={JS.navigate(~p"/")} class="mb-6">
        <.back_button />
      </button>

      <div class="max-w-2xl mx-auto">
        <header class="mb-10">
          <h1 class="text-3xl font-bold bg-gradient-to-r from-white to-zinc-500 bg-clip-text text-transparent">
            Find Friends
          </h1>
          <p class="text-zinc-500 text-sm mt-2">Search by username</p>
        </header>

        <div class="relative group mb-12">
          <div class="absolute -inset-1 bg-gradient-to-r from-emerald-500/20 to-blue-500/20 rounded-2xl blur opacity-25 group-focus-within:opacity-100 transition duration-500">
          </div>

          <.form_component search_query={@search_query} />
        </div>

        <section
          :if={!@users_empty?}
          id="users"
          phx-update="stream"
          class="space-y-3 h-[60vh] overflow-y-scroll"
        >
          <div
            :for={{dom_id, user} <- @streams.users}
            id={dom_id}
            class="flex items-center justify-between p-4 bg-zinc-900/40 border border-white/5 rounded-2xl hover:bg-zinc-900/60 hover:border-emerald-500/30 transition-all duration-300 group"
          >
            <.user_component user={user} />
          </div>
        </section>

        <div :if={@users_empty?} class="text-center py-20">
          <.empty_users_component />
        </div>
      </div>

      <.successful_contact_addition_notification
        message={@successful_contact_addition_message}
        show?={@show_successful_contact_addition_message?}
      />

      <.failed_contact_addition_notification
        message={@failed_contact_addition_message}
        show?={@show_failed_contact_addition_message?}
      />
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream_configure(:users, dom_id: &"user-#{&1.id}")
     |> assign(:failed_contact_addition_message, "")
     |> assign(:search_query, "")
     |> assign(:show_failed_contact_addition_message?, false)
     |> assign(:show_successful_contact_addition_message?, false)
     |> assign(:successful_contact_addition_message, "")}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, %{assigns: %{current_user: user}} = socket) do
    search_query = params["q"] || ""

    users = fetch_users(search_query, user.id)

    {:noreply,
     socket
     |> assign(:search_query, search_query)
     |> assign(:users_empty?, Enum.empty?(users))
     |> stream(:users, users, reset: true)}
  end

  @impl Phoenix.LiveView
  def handle_event("search_submit", %{"query" => query}, socket) do
    trimmed_query =
      query
      |> to_string()
      |> String.trim()

    if trimmed_query != "" do
      {:noreply, push_patch(socket, to: ~p"/contacts?q=#{trimmed_query}")}
    else
      {:noreply, push_patch(socket, to: ~p"/contacts")}
    end
  end

  def handle_event(
        "add_contact",
        %{"id" => contact_id},
        %{assigns: %{current_user: user}} = socket
      ) do
    attrs = %{user_id: user.id, contact_user_id: contact_id}

    case Contacts.create_contact(attrs) do
      {:ok, contact} ->
        contact = Contacts.get_contact(contact.id)

        {:noreply,
         socket
         |> assign(:show_successful_contact_addition_message?, true)
         |> assign(
           :successful_contact_addition_message,
           "#{contact.contact_user.username} was added as a contact"
         )}

      {:error, _changeset} ->
        contact = Contacts.get_contact_by_user_id_and_contact_id(contact_id, user.id)

        {:noreply,
         socket
         |> assign(
           :failed_contact_addition_message,
           "#{contact.contact_user.username} is already a contact"
         )
         |> assign(:show_failed_contact_addition_message?, true)}
    end
  end

  def handle_event("animation-finished", %{"target" => "successful-contact-addition"}, socket),
    do: {:noreply, assign(socket, :show_successful_contact_addition_message?, false)}

  def handle_event("animation-finished", %{"target" => "failed-contact-addition"}, socket),
    do: {:noreply, assign(socket, :show_failed_contact_addition_message?, false)}

  defp fetch_users(search_query, user_id) when search_query != "",
    do: Accounts.list_users(%{current_user_id: user_id, search: search_query})

  defp fetch_users(_search_query, user_id),
    do: Accounts.list_users(%{current_user_id: user_id})
end
