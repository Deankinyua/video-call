defmodule VideoCall.Calls do
  @moduledoc """
  Responsible for channeling calls, sending ice candidates and configuring streams.
  """

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
  This notifies the call initiator that their call was accepted.
  The call initiator will update the size of their video streams and the 'callee' value

  ## Parameters

    * `recipient` - The call initiator
    * `call_acceptor` - The user who accepted the call

  ## Examples

      iex> notify_remote_peer_of_call_acceptance("john", "rahab")
      :ok

  """
  @spec notify_remote_peer_of_call_acceptance(username(), username()) :: :ok
  def notify_remote_peer_of_call_acceptance(recipient, call_acceptor),
    do: send_message(recipient, {:call_accepted_by_other_peer, call_acceptor})

  @doc """
  Use this function to notify the remote peer after terminating a call.
  ## Parameters

    * `recipient` - The user to be notified of call termination.
    * `call_terminator` - The user who ended the call.

  ## Examples

      iex> notifiy_remote_peer_of_call_termination("john", "rahab")
      :ok

  """

  @spec notifiy_remote_peer_of_call_termination(username(), username()) :: :ok
  def notifiy_remote_peer_of_call_termination(recipient, call_terminator),
    do: send_message(recipient, {:call_terminated_by_other_peer, call_terminator})

  defp send_message(recipient, message) do
    Phoenix.PubSub.broadcast(
      VideoCall.PubSub,
      "calls-#{recipient}",
      message
    )
  end
end
