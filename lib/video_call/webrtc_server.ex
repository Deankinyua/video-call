defmodule VideoCall.WebrtcServer do
  @moduledoc """
  Holds call information used by the 2 peers
  """

  use GenServer

  alias VideoCall.Calls

  @type answerer :: Ecto.UUID.t()
  @type candidate_type :: atom()
  @type ice_user_id :: Ecto.UUID.t()
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

  @spec update_offer(offerer(), answerer()) :: offer_obj()
  def update_offer(offerer, answerer) do
    GenServer.call(__MODULE__, {:update_offer, offerer, answerer})
  end

  @spec get_candidates(offerer(), candidate_type()) :: list()
  def get_candidates(offerer, candidate_type) do
    GenServer.call(__MODULE__, {:get_candidates, offerer, candidate_type})
  end

  @spec add_offerer_candidate(ice_user_id(), any()) :: :ok
  def add_offerer_candidate(ice_user_id, candidate) do
    GenServer.cast(__MODULE__, {:add_offerer_candidate, ice_user_id, candidate})
  end

  @spec add_answerer_candidate(ice_user_id(), any()) :: :ok
  def add_answerer_candidate(ice_user_id, candidate) do
    GenServer.cast(__MODULE__, {:add_answerer_candidate, ice_user_id, candidate})
  end

  @spec clear_offer_object(offerer()) :: :ok
  def clear_offer_object(offerer) do
    GenServer.cast(__MODULE__, {:clear_offer_object, offerer})
  end

  @impl GenServer
  def handle_call({:new_offer, offer_object}, _from, state) do
    offers = Map.put(state.offers, offer_object.offerer, offer_object)
    state = Map.put(state, :offers, offers)

    {:reply, :ok, state}
  end

  def handle_call({:update_offer, offerer, answerer}, _from, state) do
    offer_obj = state.offers[offerer]

    updated_offer_obj = Map.put(offer_obj, :answerer, answerer)

    state = update_offer_object(updated_offer_obj, state)

    {:reply, updated_offer_obj, state}
  end

  def handle_call({:get_candidates, offerer, candidate_type}, _from, state) do
    offer_obj = state.offers[offerer]
    candidates = Map.get(offer_obj, candidate_type)

    {:reply, candidates, state}
  end

  @impl GenServer
  def handle_cast({:add_offerer_candidate, ice_user_id, candidate}, state) do
    offer_obj = state.offers[ice_user_id]

    state =
      if offer_obj do
        answerer = offer_obj.answerer
        Calls.send_ice_candidates(answerer, candidate)

        ice_candidates = [candidate | offer_obj.offerer_ice_candidates]

        updated_offer_obj = Map.put(offer_obj, :offerer_ice_candidates, ice_candidates)

        update_offer_object(updated_offer_obj, state)
      else
        state
      end

    {:noreply, state}
  end

  def handle_cast({:add_answerer_candidate, ice_user_id, candidate}, state) do
    offer_obj =
      Enum.find_value(state.offers, fn {_key, %{answerer: answerer} = value} ->
        if answerer == ice_user_id, do: value
      end)

    state =
      if offer_obj do
        offerer = offer_obj.offerer
        Calls.send_ice_candidates(offerer, candidate)

        ice_candidates = [candidate | offer_obj.answerer_ice_candidates]

        updated_offer_obj = Map.put(offer_obj, :answerer_ice_candidates, ice_candidates)

        update_offer_object(updated_offer_obj, state)
      else
        state
      end

    {:noreply, state}
  end

  def handle_cast({:clear_offer_object, offerer}, state) do
    updated_offers = Map.delete(state.offers, offerer)
    state = Map.put(state, :offers, updated_offers)
    {:noreply, state}
  end

  defp update_offer_object(offer_obj, state) do
    offers = Map.put(state.offers, offer_obj.offerer, offer_obj)
    Map.put(state, :offers, offers)
  end
end
