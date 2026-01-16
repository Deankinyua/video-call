defmodule VideoCallWeb.ContactLive.Components do
  @moduledoc """
  Contains all components rendered in the contacts liveview
  """

  use VideoCallWeb, :html

  import VideoCallWeb.Components

  alias VideoCall.Accounts.User

  @type assigns :: map()
  @type rendered :: Phoenix.LiveView.Rendered.t()

  attr :search_query, :string, required: true

  @spec form_component(assigns()) :: rendered()
  def form_component(assigns) do
    ~H"""
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
    """
  end

  attr :message, :string, required: true
  attr :show?, :boolean, required: true

  @spec successful_contact_addition_notification(assigns()) :: rendered()
  def successful_contact_addition_notification(assigns) do
    ~H"""
    <div
      :if={@show?}
      id="successful-contact-addition"
      class="fixed bottom-[16vh] left-1/2 -translate-x-1/2 z-[1100] animate-toast"
      phx-hook="Animation"
    >
      <div class="min-w-[16rem] flex items-center gap-3 p-4 rounded-2xl bg-zinc-900 text-zinc-100 shadow-2xl shadow-black/50 border border-emerald-500/20 animate-in fade-in slide-in-from-top-2">
        <section class="shrink-0 size-8 bg-emerald-500/10 rounded-full flex items-center justify-center border border-emerald-500/20">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2.5"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="size-5 text-emerald-500"
          >
            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
            <circle cx="9" cy="7" r="4"></circle>
            <line x1="19" y1="8" x2="19" y2="14"></line>
            <line x1="16" y1="11" x2="22" y2="11"></line>
          </svg>
        </section>

        <div class="flex flex-col">
          <div class="text-[13px] font-semibold text-emerald-400 leading-tight">Contact Added</div>
          <div class="text-[11px] text-zinc-400 mt-0.5 leading-tight">{@message}</div>
        </div>
      </div>
    </div>
    """
  end

  attr :message, :string, required: true
  attr :show?, :boolean, required: true

  @spec failed_contact_addition_notification(assigns()) :: rendered()
  def failed_contact_addition_notification(assigns) do
    ~H"""
    <div
      :if={@show?}
      id="failed-contact-addition"
      class="fixed bottom-[16vh] left-1/2 -translate-x-1/2 z-[1100] animate-toast"
      phx-hook="Animation"
    >
      <div class="min-w-[16rem] flex items-center gap-3 p-4 rounded-2xl bg-zinc-900 text-zinc-100 shadow-2xl shadow-black/50 border border-white/5 animate-in fade-in slide-in-from-top-2">
        <section class="shrink-0 size-8 bg-amber-500/10 rounded-full flex items-center justify-center border border-amber-500/20">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="size-5 text-amber-500"
          >
            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
            <circle cx="9" cy="7" r="4"></circle>
            <polyline points="16 11 18 13 22 9"></polyline>
          </svg>
        </section>

        <div class="flex flex-col">
          <div class="text-[13px] font-semibold text-zinc-100 leading-tight">Already Added</div>
          <div class="text-[11px] text-zinc-500 mt-0.5 leading-tight">{@message}</div>
        </div>
      </div>
    </div>
    """
  end

  attr :user, User, required: true

  @spec user_component(assigns()) :: rendered()
  def user_component(assigns) do
    ~H"""
    <div class="flex items-center gap-4">
      <div class="h-12 w-12 rounded-full overflow-hidden flex items-center justify-center text-zinc-400 font-bold">
        <.default_avatar fill="#1A1A1A" />
      </div>

      <div>
        <div class="font-medium text-zinc-100 group-hover:text-emerald-400 transition-colors">
          {@user.username}
        </div>
      </div>
    </div>

    <button
      phx-click={JS.push("add_contact", value: %{id: @user.id})}
      class="inline-flex items-center gap-2 px-5 py-2 rounded-full bg-emerald-500 hover:bg-emerald-400 text-black text-sm font-bold shadow-lg shadow-emerald-500/10 transition-all active:scale-95"
    >
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="size-4">
        <path d="M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z" />
      </svg>
      Add Contact
    </button>
    """
  end

  @spec empty_users_component(assigns()) :: rendered()
  def empty_users_component(assigns) do
    ~H"""
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
    """
  end

  @spec back_button(assigns()) :: rendered()
  def back_button(assigns) do
    ~H"""
    <svg
      width="25px"
      height="25px"
      viewBox="0 0 1024 1024"
      xmlns="http://www.w3.org/2000/svg"
      fill="#000000"
    >
      <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
      <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
      <g id="SVGRepo_iconCarrier">
        <path fill="#ffffff" d="M224 480h640a32 32 0 1 1 0 64H224a32 32 0 0 1 0-64z"></path>
        <path
          fill="#ffffff"
          d="m237.248 512 265.408 265.344a32 32 0 0 1-45.312 45.312l-288-288a32 32 0 0 1 0-45.312l288-288a32 32 0 1 1 45.312 45.312L237.248 512z"
        >
        </path>
      </g>
    </svg>
    """
  end
end
