defmodule VideoCall.ContactsTest do
  use VideoCall.DataCase, async: true

  import VideoCall.AccountsFixtures
  import VideoCall.ContactsFixtures

  alias VideoCall.Contacts
  alias VideoCall.Contacts.Contact

  defp create_contact(_attrs) do
    contact = contact_fixture()
    contact_user = user_fixture()
    user = user_fixture()
    attrs = %{contact_user_id: contact_user.id, user_id: user.id}

    %{attrs: attrs, contact: contact, user: user}
  end

  defp create_multiple_contacts(_attrs) do
    user = user_fixture()
    {3, nil} = create_multiple_contacts(user, 3)

    %{user: user}
  end

  describe "create_contact/1" do
    setup [:create_contact]

    test "creates a contact with valid attributes", %{attrs: attrs, user: user} do
      assert {:ok, %Contact{} = contact} = Contacts.create_contact(attrs)
      assert contact.user_id == user.id
    end

    test "returns error changeset with invalid attributes", %{user: user} do
      attrs = %{contact_user_id: nil, user_id: user.id}

      assert {:error, changeset} = Contacts.create_contact(attrs)
      assert %{contact_user_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns error when duplicate contact is created", %{attrs: attrs} do
      assert {:ok, %Contact{}} = Contacts.create_contact(attrs)
      assert {:error, changeset} = Contacts.create_contact(attrs)
      assert %{contact_user_id: ["You already saved this contact"]} = errors_on(changeset)
    end
  end

  describe "delete_contact/1" do
    test "deletes an existing contact" do
      contact = contact_fixture()
      assert {1, nil} = Contacts.delete_contact(contact.id)
      assert Contacts.list_contacts(%{user_id: contact.user_id}) == []
    end

    test "returns {0, nil} when contact does not exist" do
      _contact = contact_fixture()
      non_existent_id = Ecto.UUID.generate()

      assert {0, nil} = Contacts.delete_contact(non_existent_id)
    end
  end

  describe "list_contacts/2" do
    setup [:create_multiple_contacts]

    test "returns empty list when user has no contacts" do
      user = user_fixture()

      assert Contacts.list_contacts(%{user_id: user.id}) == []
    end

    test "returns contacts for a specific user", %{user: user} do
      contacts = Contacts.list_contacts(%{user_id: user.id})

      assert length(contacts) == 3
      assert hd(contacts).user_id == user.id
    end

    test "preloads contact_user associations", %{user: user} do
      [contact | _other_contacts] = Contacts.list_contacts(%{user_id: user.id})

      assert contact.user_id == user.id
      assert Ecto.assoc_loaded?(contact.contact_user)
    end

    test "recently added contacts appear first in the returned list", %{user: user} do
      contacts = Contacts.list_contacts(%{user_id: user.id})
      first_contact = Enum.at(contacts, 0)
      second_contact = Enum.at(contacts, 1)

      assert NaiveDateTime.compare(first_contact.inserted_at, second_contact.inserted_at) == :gt
    end
  end
end
