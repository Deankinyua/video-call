defmodule VideoCall.Calls do
  @moduledoc """
  Responsible for notifying someone of an incoming call.
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
  @spec subscribe(user_id()) :: :ok
  def subscribe(user_id) do
    Phoenix.PubSub.subscribe(VideoCall.PubSub, "calls-#{user_id}")
  end

  @doc """
  Dispatches a call to a specific user.

  ## Examples

      iex>

  """
  @spec call(user_id(), username(), caller_id()) :: :ok
  def call(recipient_id, caller_username, caller_id),
    do: send_message(recipient_id, {:new_call, caller_username, caller_id})

  @spec send_ice_candidates(user_id(), any()) :: :ok
  def send_ice_candidates(recipient_id, candidate),
    do: send_message(recipient_id, {:new_candidate, candidate})

  @spec send_answer_to_offerer(user_id(), any()) :: :ok
  def send_answer_to_offerer(recipient_id, answer),
    do: send_message(recipient_id, {:answer_to_offer, answer})

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
