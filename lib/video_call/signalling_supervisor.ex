defmodule VideoCall.SignallingSupervisor do
  @moduledoc """
  Responsible for dynamically starting WebRTC servers.
  Each server is responsible for one call and one call alone!
  """

  use DynamicSupervisor

  alias VideoCall.SignallingRegistry
  alias VideoCall.WebrtcServer

  @type genserver :: String.t()

  @spec start_link(any()) :: {:ok, pid()} | {:error, any()}
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl DynamicSupervisor
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_server(genserver()) :: DynamicSupervisor.on_start_child()
  def start_server(genserver),
    do: DynamicSupervisor.start_child(__MODULE__, {WebrtcServer, name: via_registry(genserver)})

  @spec stop_server(genserver()) :: :ok
  def stop_server(genserver) do
    genserver
    |> via_registry()
    |> GenServer.stop(:normal, 5000)
  end

  defp via_registry(name), do: {:via, Registry, {SignallingRegistry, name}}
end
