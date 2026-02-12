defmodule VideoCallWeb.Router do
  use VideoCallWeb, :router

  import VideoCallWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VideoCallWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  # pipeline :api do
  #   plug :accepts, ["json"]
  # end

  # Other scopes may use custom stacks.
  # scope "/api", VideoCallWeb do
  #   pipe_through :api
  # end

  scope "/", VideoCallWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{VideoCallWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/", HomeLive.Index, :index
    end
  end

  scope "/", VideoCallWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{VideoCallWeb.UserAuth, :ensure_authenticated}] do
      live "/call", VideoLive.Index, :index
      live "/contacts", ContactLive.Index, :index
    end
  end

  scope "/auth", VideoCallWeb do
    pipe_through :browser

    get "/logout", AuthController, :logout

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:video_call, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VideoCallWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
