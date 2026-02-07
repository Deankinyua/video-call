defmodule VideoCall.WebrtcServer do
  @moduledoc """
  Holds call information used by the 2 peers
  """

  use GenServer, restart: :transient

  alias VideoCall.Calls
  alias VideoCall.SignallingRegistry

  @type answerer :: Ecto.UUID.t()
  @type candidate_type :: atom()
  @type genserver :: String.t()
  @type ice_user_id :: Ecto.UUID.t()
  @type offer_obj :: map()
  @type offer_obj_id :: String.t()
  @type offerer :: Ecto.UUID.t()

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{offers: %{}}, opts)
  end

  @impl GenServer
  def init(state), do: {:ok, state}

  @spec store_offer(genserver(), map()) :: :ok
  def store_offer(genserver, offer_object),
    do: make_genserver_request(genserver, :call, {:new_offer, offer_object})

  @spec update_offer(genserver(), offer_obj_id(), answerer()) :: offer_obj()
  def update_offer(genserver, offer_obj_id, answerer),
    do: make_genserver_request(genserver, :call, {:update_offer, offer_obj_id, answerer})

  @spec get_candidates(genserver(), offer_obj_id(), candidate_type()) :: list()
  def get_candidates(genserver, offer_obj_id, candidate_type),
    do: make_genserver_request(genserver, :call, {:get_candidates, offer_obj_id, candidate_type})

  @spec add_offerer_candidate(genserver(), ice_user_id(), any()) :: :ok
  def add_offerer_candidate(genserver, ice_user_id, candidate),
    do: make_genserver_request(genserver, :cast, {:add_offerer_candidate, ice_user_id, candidate})

  @spec add_answerer_candidate(genserver(), ice_user_id(), any()) :: :ok
  def add_answerer_candidate(genserver, ice_user_id, candidate),
    do:
      make_genserver_request(genserver, :cast, {:add_answerer_candidate, ice_user_id, candidate})

  @spec clear_offer_object(genserver(), offer_obj_id()) :: :ok
  def clear_offer_object(genserver, offer_obj_id),
    do: make_genserver_request(genserver, :cast, {:clear_offer_object, offer_obj_id})

  @impl GenServer
  def handle_call({:new_offer, offer_object}, _from, state) do
    offers = Map.put(state.offers, offer_object.offerer, offer_object)
    state = Map.put(state, :offers, offers)

    {:reply, :ok, state}
  end

  def handle_call({:update_offer, offer_obj_id, answerer}, _from, state) do
    offer_obj = state.offers[offer_obj_id]

    updated_offer_obj = Map.put(offer_obj, :answerer, answerer)

    state = update_offer_object(updated_offer_obj, state)

    {:reply, updated_offer_obj, state}
  end

  def handle_call({:get_candidates, offer_obj_id, candidate_type}, _from, state) do
    offer_obj = state.offers[offer_obj_id]
    candidates = Map.get(offer_obj, candidate_type)

    {:reply, candidates, state}
  end

  @impl GenServer
  def handle_cast({:add_offerer_candidate, ice_user_id, candidate}, state) do
    offer_obj = state.offers[ice_user_id]

    state =
      if offer_obj do
        answerer = offer_obj.answerer
        Calls.send_ice_candidate(answerer, candidate)

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
        Calls.send_ice_candidate(offerer, candidate)

        ice_candidates = [candidate | offer_obj.answerer_ice_candidates]

        updated_offer_obj = Map.put(offer_obj, :answerer_ice_candidates, ice_candidates)

        update_offer_object(updated_offer_obj, state)
      else
        state
      end

    {:noreply, state}
  end

  def handle_cast({:clear_offer_object, offer_obj_id}, state) do
    updated_offers = Map.delete(state.offers, offer_obj_id)
    state = Map.put(state, :offers, updated_offers)
    {:noreply, state}
  end

  defp update_offer_object(offer_obj, state) do
    offers = Map.put(state.offers, offer_obj.offerer, offer_obj)
    Map.put(state, :offers, offers)
  end

  defp make_genserver_request(genserver, request_type, message) when request_type == :call do
    genserver
    |> via_registry()
    |> GenServer.call(message)
  end

  defp make_genserver_request(genserver, _request_type, message) do
    genserver
    |> via_registry()
    |> GenServer.cast(message)
  end

  defp via_registry(name), do: {:via, Registry, {SignallingRegistry, name}}
end
