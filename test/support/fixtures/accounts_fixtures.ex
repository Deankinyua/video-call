defmodule VideoCall.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VideoCall.Accounts` context.
  """

  import VideoCall.PaginationHelpers

  alias VideoCall.Accounts.User

  @type attrs :: map()
  @type user :: User.t()

  @doc """
  Generate a unique user email.
  """
  @spec unique_user_email :: String.t()
  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  @spec unique_username :: String.t()
  def unique_username, do: "user#{System.unique_integer()}kenya"

  @doc """
  Generate a user.
  """
  @spec user_fixture(attrs()) :: user()
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        avatar: "https://lh3.googleusercontent.com/a/anything",
        email: unique_user_email(),
        username: unique_username()
      })
      |> VideoCall.Accounts.register_user()

    user
  end

  @spec create_multiple_users(integer()) :: [user()]
  def create_multiple_users(number_of_users) do
    for index <- 1..number_of_users do
      offset_time = 120 * index

      update_inserted_at(user_fixture(), offset_time)
    end
  end
end
