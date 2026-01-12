defmodule VideoCall.Contacts do
  @moduledoc """
  The Contacts context.
  """

  import Ecto.Query, warn: false

  alias VideoCall.Contacts.Contact
  alias VideoCall.Repo

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type contact :: Contact.t()

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%{user_id: "550e8400-e29b-41d4-a716-446655440000"})
      {:ok, %Contact{}}

      iex> create_contact(%{user_id: "non-existent-id"})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_contact(attrs()) :: {:ok, contact()} | {:error, changeset()}
  def create_contact(attrs) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end
end
