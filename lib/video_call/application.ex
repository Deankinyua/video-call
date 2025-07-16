defmodule VideoCall.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      VideoCallWeb.Telemetry,
      VideoCall.Repo,
      {DNSCluster, query: Application.get_env(:video_call, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: VideoCall.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: VideoCall.Finch},
      # Start a worker by calling: VideoCall.Worker.start_link(arg)
      # {VideoCall.Worker, arg},
      # Start to serve requests, typically the last entry
      VideoCallWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VideoCall.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl Application
  def config_change(changed, _new, removed) do
    VideoCallWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
