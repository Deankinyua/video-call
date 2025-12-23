defmodule VideoCall.WebrtcServer do
  @moduledoc """
  Holds call information used by the 2 peers
  """

  use GenServer

  @type offer_obj :: map()
  @type offerer :: Ecto.UUID.t()

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_state) do
    {:ok, %{offers: %{}}}
  end

  @spec store_offer(map()) :: :ok
  def store_offer(offer_object) do
    GenServer.call(__MODULE__, {:new_offer, offer_object})
  end

  @spec get_offer(offerer()) :: offer_obj()
  def get_offer(offerer) do
    GenServer.call(__MODULE__, {:get_offer, offerer})
  end

  @impl GenServer
  def handle_call({:new_offer, offer_object}, _from, state) do
    offers = Map.put(state.offers, offer_object.offerer, offer_object)
    state = Map.put(state, :offers, offers)

    {:reply, :ok, state}
  end

  def handle_call({:get_offer, offerer}, _from, state) do
    offer_obj = state.offers[offerer]

    {:reply, offer_obj, state}
  end
end
