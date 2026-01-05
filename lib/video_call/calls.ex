defmodule VideoCall.Calls do
  @moduledoc """
  Responsible for channeling calls and sending ice candidates.
  """

  @type caller_id :: Ecto.UUID.t()
  @type larger_stream :: atom()
  @type user_id :: Ecto.UUID.t()
  @type username :: String.t()

  @doc """
  Subscribes to call events for a specific user.

  ## Examples

      iex> subscribe("moses")
      :ok

  """
  @spec subscribe(username()) :: :ok | {:error, term()}
  def subscribe(username) do
    Phoenix.PubSub.subscribe(VideoCall.PubSub, "calls-#{username}")
  end

  @doc """
  Notifies a person of an incoming call.

  ## Parameters

    * `recipient` - The user receiving the call
    * `caller` - The call initiator

  ## Examples

      iex> call("james", "john")
      :ok

  """
  @spec call(username(), username()) :: :ok
  def call(recipient, caller),
    do: send_message(recipient, {:incoming_call, caller})

  @doc """
  Sends ICE candidates to a specific user for WebRTC connection establishment.

  ICE (Interactive Connectivity Establishment) candidates are used to negotiate
  the best path for peer-to-peer communication between callers.

  ## Parameters

    * `recipient` - The user receiving the ICE candidate
    * `candidate` - The ICE candidate data from the WebRTC connection

  ## Examples

      iex> send_ice_candidates("john", %{"candidate" => "...", "sdpMid" => "0"})
      :ok

  """
  @spec send_ice_candidates(username(), any()) :: :ok
  def send_ice_candidates(recipient, candidate),
    do: send_message(recipient, {:new_candidate, candidate})

  @doc """
  Sends an SDP answer back to the call offerer to complete the WebRTC handshake.

  After the callee receives an SDP offer, they generate an answer which must
  be sent back to the offerer to establish the peer connection.

  ## Parameters

    * `offerer` - The original offerer receiving the answer
    * `answer` - The SDP answer data from the WebRTC connection

  ## Examples

      iex> send_answer_to_offerer("jacob", %{"type" => "answer", "sdp" => "..."})
      :ok

  """
  @spec send_answer_to_offerer(username(), any()) :: :ok
  def send_answer_to_offerer(offerer, answer),
    do: send_message(offerer, {:answer_to_offer, answer})

  @doc """
  Notifies a person that their call has been declined.

  ## Parameters

    * `caller` - The call initiator
    * `callee` - The person who was called

  ## Examples

      iex> send_decline_call_notification("jacob", "john")
      :ok

  """

  @spec send_decline_call_notification(username(), username()) :: :ok
  def send_decline_call_notification(caller, callee),
    do: send_message(caller, {:call_declined, callee})

  @doc """
  Notifies a user to switch their call view state.

  Broadcasts a `:switch_view` message to trigger a UI state change,
  typically used when the call is answered and both parties should
  transition from the calling/ringing state to the active call view.

  ## Parameters

    * `recipient` - The id of the user who should switch their view

  ## Examples

      iex> switch_caller_view("550e8400-e29b-41d4-a716-446655440000")
      :ok

  """
  @spec switch_caller_view(user_id(), larger_stream()) :: :ok
  def switch_caller_view(recipient, :remote_large),
    do: send_message(recipient, :switch_remote_stream_to_large)

  def switch_caller_view(recipient, :local_large),
    do: send_message(recipient, :switch_local_stream_to_large)

  defp send_message(recipient, message) do
    Phoenix.PubSub.broadcast(
      VideoCall.PubSub,
      "calls-#{recipient}",
      message
    )
  end
end
