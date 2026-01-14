defmodule VideoCallWeb.ContactLive.Index do
  use VideoCallWeb, :live_view

  alias VideoCall.Accounts
  # alias VideoCall.Contacts
  # alias VideoCall.Contacts.Contact

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="border border-red-400">
      <form phx-submit={JS.push("search_submit")} class="relative flex items-center">
        <.icon name="hero-magnifying-glass" class="absolute left-3 h-4 w-4 text-gray-500" />
        <input
          id="search-username"
          type="text"
          name="query"
          value={@search_query}
          placeholder="Type friend's username"
          class={[
            "pl-10 pr-4 py-2 bg-transparent border-0",
            "focus:outline-none focus:ring-0 placeholder-gray-500 text-sm",
            "min-w-[200px]"
          ]}
        />
      </form>

      <section id="nice_one" phx-update="stream"></section>
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
  def handle_params(params, _url, socket) do
    search_query = params["q"] || ""

    users = fetch_users(search_query)

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

  defp fetch_users(search_query) when search_query != "",
    do: Accounts.list_users(%{search: search_query})

  defp fetch_users(_search_query), do: Accounts.list_users()
end
