defmodule VideoCall.Calls do
  @moduledoc """
  Responsible for notifying someone of an incoming call.
  """

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

      iex> call("550e8400-e29b-41d4-a716-446655440000", "dean")
      :ok

  """
  @spec call(user_id(), username()) :: :ok
  def call(recipient_id, caller_username) do
    Phoenix.PubSub.broadcast(
      VideoCall.PubSub,
      "calls-#{recipient_id}",
      {:new_call, caller_username}
    )
  end
end
