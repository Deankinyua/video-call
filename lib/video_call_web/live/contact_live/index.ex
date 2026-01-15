defmodule VideoCallWeb.ContactLive.Index do
  use VideoCallWeb, :live_view

  alias VideoCall.Accounts
  alias VideoCall.Contacts
  alias VideoCallWeb.VideoComponents

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="h-screen overflow-hidden bg-black text-zinc-100 p-6 sm:p-12">
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

          <form
            phx-submit="search_submit"
            class="relative flex items-center bg-zinc-900 border border-white/10 rounded-xl overflow-hidden focus-within:border-emerald-500/50 transition-all"
          >
            <div class="pl-4 text-zinc-500">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="2"
                stroke="currentColor"
                class="size-5"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"
                />
              </svg>
            </div>

            <input
              id="search-username"
              type="text"
              name="query"
              value={@search_query}
              placeholder="Type friend's username..."
              class="w-full pl-3 pr-4 py-4 bg-transparent border-0 focus:ring-0 text-base placeholder-zinc-600 text-white"
            />

            <button class="mr-3 px-4 py-1.5 bg-zinc-800 hover:bg-zinc-700 border border-white/5 rounded-lg text-xs font-semibold transition-colors">
              Search
            </button>
          </form>
        </div>

        <section
          :if={!@users_empty?}
          id="users"
          phx-update="stream"
          class="space-y-3 h-[70vh] overflow-y-scroll"
        >
          <div
            :for={{dom_id, user} <- @streams.users}
            id={dom_id}
            class="flex items-center justify-between p-4 bg-zinc-900/40 border border-white/5 rounded-2xl hover:bg-zinc-900/60 hover:border-emerald-500/30 transition-all duration-300 group"
          >
            <div class="flex items-center gap-4">
              <div class="h-12 w-12 rounded-full overflow-hidden flex items-center justify-center text-zinc-400 font-bold">
                <VideoComponents.default_avatar fill="#1A1A1A" />
              </div>

              <div>
                <div class="font-medium text-zinc-100 group-hover:text-emerald-400 transition-colors">
                  {user.username}
                </div>
              </div>
            </div>

            <button
              phx-click={JS.push("add_contact", value: %{id: user.id})}
              class="inline-flex items-center gap-2 px-5 py-2 rounded-full bg-emerald-500 hover:bg-emerald-400 text-black text-sm font-bold shadow-lg shadow-emerald-500/10 transition-all active:scale-95"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 20 20"
                fill="currentColor"
                class="size-4"
              >
                <path d="M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z" />
              </svg>
              Add Contact
            </button>
          </div>
        </section>

        <div :if={@users_empty?} class="text-center py-20">
          <div class="inline-flex items-center justify-center h-16 w-16 rounded-full bg-zinc-900 text-zinc-700 mb-4">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="size-8"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M18 7.5v3m0 0v3m0-3h3m-3 0h-3m-2.25-4.125a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0ZM3 19.235v-.11a6.375 6.375 0 0 1 12.75 0v.109A12.318 12.318 0 0 1 9.374 21c-2.331 0-4.512-.645-6.374-1.766Z"
              />
            </svg>
          </div>
          <p class="text-zinc-500 italic">Ooops!! No users were found.</p>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream_configure(:users, dom_id: &"user-#{&1.id}")
     |> assign(:search_query, "")}
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
      {:ok, user} ->
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, socket}
    end
  end

  defp fetch_users(search_query, user_id) when search_query != "",
    do: Accounts.list_users(%{current_user_id: user_id, search: search_query})

  defp fetch_users(_search_query, user_id),
    do: Accounts.list_users(%{current_user_id: user_id})
end
