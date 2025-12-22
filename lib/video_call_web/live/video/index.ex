defmodule VideoCallWeb.VideoLive.Index do
  use VideoCallWeb, :live_view

  import VideoCallWeb.ContactComponents

  alias VideoCall.Accounts

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div id="video-parent" class="relative" phx-hook="RtcConnection">
      <div class="ml-4 mt-28 w-[60%] border border-red-400">
        <div class="">
          <div id="user-name">You</div>
        </div>
        <div id="videos" class="flex flex-col gap-4">
          <div>
            <video
              class="w-[30rem] h-[20rem]  local-video"
              id="local-video"
              autoplay
              playsinline
              controls
            >
            </video>
          </div>
          <div>
            <video
              class="w-[30rem] h-[20rem] remote-video"
              id="remote-video"
              autoplay
              playsinline
              controls
            >
            </video>
          </div>
        </div>
      </div>

      <div id="contacts" class="w-[24rem] absolute top-8 right-8">
        <div class="mb-2">Contacts</div>
        <div :for={contact <- @contacts}>
          <.contact_component username={contact.username} />
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    contacts = Accounts.list_users()

    {:ok, assign(socket, :contacts, contacts)}
  end
end
