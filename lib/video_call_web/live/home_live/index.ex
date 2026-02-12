defmodule VideoCallWeb.HomeLive.Index do
  use VideoCallWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-zinc-950 text-zinc-100 flex flex-col items-center justify-center px-6">
      <div class="mb-12 text-center">
        <h1 class="text-4xl md:text-6xl font-black tracking-tighter bg-gradient-to-r from-indigo-400 to-cyan-400 bg-clip-text text-transparent">
          Easy Video Call
        </h1>
        <p class="mt-4 text-zinc-400 text-lg">Simple. Private. Fast.</p>
      </div>

      <div class="flex flex-col items-center gap-8">
        <.link
          href={~p"/auth/google"}
          class="group relative inline-flex items-center justify-center px-8 py-4 font-bold text-white transition-all duration-200 bg-indigo-600 font-pj rounded-xl focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-600 hover:bg-indigo-500 shadow-lg shadow-indigo-500/20"
        >
          <img class="h-5 w-5 mr-3" src="https://www.svgrepo.com/show/355037/google.svg" alt="Google" />
          Sign In with Google
        </.link>

        <div class="mt-8 space-y-4 text-left">
          <h3 class="text-zinc-500 uppercase tracking-widest text-xs font-semibold mb-4 text-center">
            How it works
          </h3>
          <ul class="space-y-3">
            <li class="flex items-center gap-3">
              <span class="w-1.5 h-1.5 rounded-full bg-indigo-500"></span>
              <span class="text-zinc-300">Sign in with your Google account.</span>
            </li>
            <li class="flex items-center gap-3">
              <span class="w-1.5 h-1.5 rounded-full bg-indigo-500"></span>
              <span class="text-zinc-300">Search and add a contact by their username.</span>
            </li>
            <li class="flex items-center gap-3">
              <span class="w-1.5 h-1.5 rounded-full bg-indigo-500"></span>
              <span class="text-zinc-300">Open the contacts drawer and call someone!</span>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end
end
