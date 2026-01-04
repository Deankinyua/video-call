defmodule VideoCall.Calls do
  @moduledoc """
  Responsible for channeling calls and sending ice candidates.
  """
  @type caller_id :: Ecto.UUID.t()
  @type user_id :: Ecto.UUID.t()
  @type username :: String.t()

  @doc """
  Subscribes to call events for a specific user.

  ## Examples

      iex> subscribe("550e8400-e29b-41d4-a716-446655440000")
      :ok

  """
  @spec subscribe(user_id()) :: :ok | {:error, term()}
  def subscribe(user_id) do
    Phoenix.PubSub.subscribe(VideoCall.PubSub, "calls-#{user_id}")
  end

  @doc """
  Notifies a person of an icoming call.

  ## Parameters

    * `recipient_id` - The id of the user receiving the call
    * `caller_username` - The username of the call initiator
    * `caller_id` - The id of the call initiator

  ## Examples

      iex> call("550e8400-e29b-41d4-a716-446655440000", "john_doe", "660e8400-e29b-41d4-a716-4466554403430")
      :ok

  """
  @spec call(user_id(), username(), caller_id()) :: :ok
  def call(recipient_id, caller_username, caller_id),
    do: send_message(recipient_id, {:new_call, caller_username, caller_id})

  @doc """
  Sends ICE candidates to a specific user for WebRTC connection establishment.

  ICE (Interactive Connectivity Establishment) candidates are used to negotiate
  the best path for peer-to-peer communication between callers.

  ## Parameters

    * `recipient_id` - The id of the user receiving the ICE candidate
    * `candidate` - The ICE candidate data from the WebRTC connection

  ## Examples

      iex> send_ice_candidates("550e8400-e29b-41d4-a716-446655440000", %{"candidate" => "...", "sdpMid" => "0"})
      :ok

  """
  @spec send_ice_candidates(user_id(), any()) :: :ok
  def send_ice_candidates(recipient_id, candidate),
    do: send_message(recipient_id, {:new_candidate, candidate})

  @doc """
  Sends an SDP answer back to the call offerer to complete the WebRTC handshake.

  After the callee receives an SDP offer, they generate an answer which must
  be sent back to the offerer to establish the peer connection.

  ## Parameters

    * `recipient_id` - The id of the original offerer receiving the answer
    * `answer` - The SDP answer data from the WebRTC connection

  ## Examples

      iex> send_answer_to_offerer("550e8400-e29b-41d4-a716-446655440000", %{"type" => "answer", "sdp" => "..."})
      :ok

  """
  @spec send_answer_to_offerer(user_id(), any()) :: :ok
  def send_answer_to_offerer(recipient_id, answer),
    do: send_message(recipient_id, {:answer_to_offer, answer})

  @doc """
  Notifies a person that their call has been declined.

  ## Parameters

    * `recipient_id` - The id of the call initiator
    * `callee_username` - The username of the person who was called

  ## Examples

      iex> send_decline_call_notification("550e8400-e29b-41d4-a716-446655440000", "john_doe")
      :ok

  """

  @spec send_decline_call_notification(user_id(), username()) :: :ok
  def send_decline_call_notification(recipient_id, callee_username),
    do: send_message(recipient_id, {:call_declined, callee_username})

  @doc """
  Notifies a user to switch their call view state.

  Broadcasts a `:switch_view` message to trigger a UI state change,
  typically used when the call is answered and both parties should
  transition from the calling/ringing state to the active call view.

  ## Parameters

    * `recipient_id` - The id of the user who should switch their view

  ## Examples

      iex> switch_caller_view("550e8400-e29b-41d4-a716-446655440000")
      :ok

  """
  @spec switch_caller_view(user_id()) :: :ok
  def switch_caller_view(recipient_id),
    do: send_message(recipient_id, :switch_view)

  defp send_message(recipient_id, message) do
    Phoenix.PubSub.broadcast(
      VideoCall.PubSub,
      "calls-#{recipient_id}",
      message
    )
  end
end
