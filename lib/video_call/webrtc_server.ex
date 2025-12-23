defmodule VideoCall.WebrtcServer do
  @moduledoc """
  Holds call information used by the 2 peers
  """

  use GenServer

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_state) do
    {:ok, %{offers: []}}
  end

  @spec store_offer(map()) :: :ok
  def store_offer(offer_object) do
    GenServer.call(__MODULE__, {:new_offer, offer_object})
  end

  @impl GenServer
  def handle_call({:new_offer, offer_object}, _from, state) do
    offers = [offer_object | state.offers]
    state = Map.put(state, :offers, offers)

    {:reply, :ok, state}
  end
end
