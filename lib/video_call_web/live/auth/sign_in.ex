defmodule VideoCallWeb.AuthLive.SignIn do
  use VideoCallWeb, :live_view

  alias VideoCall.Accounts
  alias VideoCall.Accounts.User

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex items-center h-screen">
      <div class="w-[70%] mx-auto">
        <.header class="text-center">
          Log in to account
          <:subtitle>
            Don't have an account?
            <.link navigate={~p"/sign-up"} class="font-semibold text-brand hover:underline">
              Sign up
            </.link>
            for an account now.
          </:subtitle>
        </.header>
        <.simple_form for={@form} id="login_form" action={~p"/sign-in"} phx-update="ignore">
          <.input
            field={@form[:email]}
            type="email"
            label="Email"
            placeholder="johndoe@gmail.com"
            required
          />
          <.input field={@form[:password]} type="password" label="Password" required />
          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          </:actions>
          <:actions>
            <.button phx-disable-with="Logging in..." class="w-full">
              Log in <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email)

    form =
      %User{}
      |> Accounts.change_user_registration(%{email: email})
      |> to_form(as: "user")

    {:ok, assign(socket, :form, form), temporary_assigns: [form: form]}
  end
end
