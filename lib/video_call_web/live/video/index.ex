defmodule VideoCallWeb.VideoLive.Index do
  use VideoCallWeb, :live_view

  import VideoCallWeb.ContactComponents

  alias VideoCall.Accounts

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center relative">
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
