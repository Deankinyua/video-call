defmodule VideoCall.ContactsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VideoCall.Contacts` context.
  """

  import VideoCall.AccountsFixtures

  alias VideoCall.Accounts.User
  alias VideoCall.Contacts
  alias VideoCall.Contacts.Contact
  alias VideoCall.Repo

  @type attrs :: map()
  @type contact :: Contact.t()
  @type user :: User.t()

  @doc """
  Generate a contact.
  """
  @spec contact_fixture(attrs()) :: contact()
  def contact_fixture(attrs \\ %{}) do
    user = user_fixture()
    contact_user = user_fixture()

    {:ok, contact} =
      attrs
      |> Enum.into(%{
        contact_user_id: contact_user.id,
        user_id: user.id
      })
      |> Contacts.create_contact()

    contact
  end

  @doc """
  Creates multiple contacts.
  """
  @spec create_multiple_contacts(user(), integer()) :: {non_neg_integer(), nil}
  def create_multiple_contacts(user, count) do
    now = NaiveDateTime.utc_now()

    entries =
      for index <- 1..count do
        contact_user = user_fixture()

        %{
          user_id: user.id,
          contact_user_id: contact_user.id,
          inserted_at: update_time(now, index),
          updated_at: update_time(now, index)
        }
      end

    Repo.insert_all(Contact, entries)
  end

  defp update_time(naive_time, index, offset \\ 120) do
    naive_time
    |> NaiveDateTime.add(index * offset)
    |> NaiveDateTime.truncate(:second)
  end
end
