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
  @type offer_obj :: map()

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts), do: GenServer.start_link(__MODULE__, %{offer: nil}, opts)

  @impl GenServer
  def init(state), do: {:ok, state}

  @spec store_offer(genserver(), map()) :: :ok
  def store_offer(genserver, offer_object),
    do: make_genserver_request(genserver, :call, {:new_offer, offer_object})

  @spec update_offer(genserver(), answerer()) :: offer_obj()
  def update_offer(genserver, answerer),
    do: make_genserver_request(genserver, :call, {:update_offer, answerer})

  @spec get_candidates(genserver(), candidate_type()) :: list()
  def get_candidates(genserver, candidate_type),
    do: make_genserver_request(genserver, :call, {:get_candidates, candidate_type})

  @spec add_offerer_candidate(genserver(), any()) :: :ok
  def add_offerer_candidate(genserver, candidate),
    do: make_genserver_request(genserver, :cast, {:add_offerer_candidate, candidate})

  @spec add_answerer_candidate(genserver(), any()) :: :ok
  def add_answerer_candidate(genserver, candidate),
    do: make_genserver_request(genserver, :cast, {:add_answerer_candidate, candidate})

  @impl GenServer
  def handle_call({:new_offer, offer_object}, _from, _state) do
    {:reply, :ok, %{offer: offer_object}}
  end

  def handle_call({:update_offer, answerer}, _from, %{offer: offer_obj}) do
    updated_offer_obj = Map.put(offer_obj, :answerer, answerer)
    {:reply, updated_offer_obj, %{offer: updated_offer_obj}}
  end

  def handle_call({:get_candidates, candidate_type}, _from, %{offer: offer_obj} = state) do
    candidates = Map.get(offer_obj, candidate_type)
    {:reply, candidates, state}
  end

  @impl GenServer
  def handle_cast({:add_offerer_candidate, candidate}, %{offer: offer_obj} = state) do
    if offer_obj do
      Calls.send_ice_candidate(offer_obj.answerer, candidate)
      ice_candidates = [candidate | offer_obj.offerer_ice_candidates]
      updated_offer_obj = Map.put(offer_obj, :offerer_ice_candidates, ice_candidates)
      {:noreply, %{offer: updated_offer_obj}}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:add_answerer_candidate, candidate}, %{offer: offer_obj} = state) do
    if offer_obj do
      Calls.send_ice_candidate(offer_obj.offerer, candidate)
      ice_candidates = [candidate | offer_obj.answerer_ice_candidates]
      updated_offer_obj = Map.put(offer_obj, :answerer_ice_candidates, ice_candidates)
      {:noreply, %{offer: updated_offer_obj}}
    else
      {:noreply, state}
    end
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
