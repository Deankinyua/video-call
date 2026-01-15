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
  @type contact_id :: Ecto.UUID.t()
  @type filters :: map()
  @type id :: Ecto.UUID.t()

  @doc """
  Gets a single contact by id.

  Returns `nil` if the contact does not exist.

  ## Examples

      iex> get_contact("550e8400-e29b-41d4-a716-446655440000")
      %Contact{}

      iex> get_contact("non-existent-id")
      nil

  """
  @spec get_contact(id()) :: contact()
  def get_contact(id) do
    Contact
    |> where([c], c.id == ^id)
    |> preload([:contact_user])
    |> Repo.one()
  end

  @doc """
  Gets a contact by the contact_user_id and the owner's user_id.

  Returns `nil` if no matching contact is found.

  ## Examples

      iex> get_contact_by_user_id_and_contact_id("550e8400-e29b-41d4-a716-446655440000", "550e8400-e29b-41d4-a676-449955440000")
      %Contact{}

      iex> get_contact_by_user_id_and_contact_id("non-existent-id", "owner-user-id")
      nil

  """
  @spec get_contact_by_user_id_and_contact_id(id(), id()) :: contact()
  def get_contact_by_user_id_and_contact_id(contact_user_id, user_id) do
    Contact
    |> where([c], c.contact_user_id == ^contact_user_id and c.user_id == ^user_id)
    |> preload([:contact_user])
    |> Repo.one()
  end

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%{user_id: "550e8400-e29b-41d4-a716-446655440000", contact_user_id: "530e8400-e29b-41d4-a716-44665544000"})
      {:ok, %Contact{}}

      iex> create_contact(%{user_id: "non-existent-id", contact_user_id: nil})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_contact(attrs()) :: {:ok, contact()} | {:error, changeset()}
  def create_contact(attrs) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> validate_contact_not_current_user(attrs)
    |> Repo.insert()
  end

  defp validate_contact_not_current_user(
         changeset,
         %{user_id: user_id, contact_user_id: contact_user_id} = _attrs
       ) do
    case user_id == contact_user_id do
      true ->
        Ecto.Changeset.add_error(changeset, :user_id, "You cannot add yourself as a contact")

      false ->
        changeset
    end
  end

  @doc """
  Deletes a contact.

  ## Examples

      iex> delete_contact("550e8400-e29b-41d4-a716-446655440000")
      {1, nil}

  """
  @spec delete_contact(contact_id()) :: {non_neg_integer(), nil}
  def delete_contact(contact_id) do
    Contact
    |> where([c], c.id == ^contact_id)
    |> Repo.delete_all()
  end

  @doc """
  Returns a list of contacts filtered by the given filters with cursor data.

   ## Examples

      iex> list_contacts(%{user_id: user_id})
      [%Contact{}, ...]

      iex> list_contacts(%{older_than: %Contact{}})
      [%Contact{}, ...]

  """

  @spec list_contacts(filters()) :: [contact()]
  def list_contacts(filters) do
    filter_query = apply_filters()

    contact_query()
    |> where(^filter_query.(filters))
    |> limit(10)
    |> preload([:contact_user])
    |> order_by([u], {:desc, u.inserted_at})
    |> Repo.all()
  end

  defp contact_query do
    from contact in Contact, as: :contact
  end

  defp apply_filters do
    fn filters ->
      Enum.reduce(filters, dynamic(true), &apply_filter/2)
    end
  end

  defp apply_filter({:older_than, contact}, dynamic) do
    dynamic([contact: contact], ^dynamic and contact.inserted_at < ^contact.inserted_at)
  end

  defp apply_filter({:user_id, user_id}, dynamic) do
    dynamic([contact: contact], ^dynamic and contact.user_id == ^user_id)
  end

  defp apply_filter(_other, dynamic), do: dynamic
end
