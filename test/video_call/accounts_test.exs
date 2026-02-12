defmodule VideoCall.AccountsTest do
  use VideoCall.DataCase, async: true

  import VideoCall.AccountsFixtures

  alias VideoCall.Accounts
  alias VideoCall.Accounts.UserToken

  defp create_user_and_token(_attrs) do
    user = user_fixture()
    token = Accounts.generate_user_session_token(user)
    %{user: user, token: token}
  end

  describe "get_or_create_user/1" do
    setup [:create_user_and_token]

    test "returns a user with the existing credentials if they exist", %{user: user} do
      assert {:ok, retrieved_user} = Accounts.get_or_create_user(user)
      assert retrieved_user.email == user.email
    end

    test "creates a user with the credentials if one doesn't exist" do
      attrs = %{
        avatar: "https://random.avatar",
        email: "onegoodemail@email.com",
        username: "agoodusername"
      }

      assert {:ok, retrieved_user} = Accounts.get_or_create_user(attrs)
      assert retrieved_user.avatar == attrs.avatar
      assert retrieved_user.email == attrs.email
      assert retrieved_user.username == attrs.username
    end

    test "fails to create a new user with invalid params" do
      attrs = %{
        avatar: "",
        email: "",
        username: ""
      }

      assert {:error, changeset} = Accounts.get_or_create_user(attrs)

      assert %{
               avatar: ["can't be blank"],
               email: ["can't be blank"],
               username: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  describe "get_user_by_email/1" do
    setup [:create_user_and_token]

    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists", %{user: user} do
      retrieved_user = Accounts.get_user_by_email(user.email)

      assert retrieved_user.email == user.email
    end
  end

  describe "get_user!/1" do
    setup [:create_user_and_token]

    test "raises if id is invalid" do
      refute Accounts.get_user!("3fba600c-a810-4555-b5f2-9c52fe5c1012")
    end

    test "returns the user with the given id", %{user: user} do
      assert Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires avatar, email and username to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               avatar: ["can't be blank"],
               email: ["can't be blank"],
               username: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email uniqueness" do
      user = user_fixture()

      {:error, changeset} =
        Accounts.register_user(%{avatar: user.avatar, email: user.email, username: user.username})

      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset_2} =
        Accounts.register_user(%{
          avatar: user.avatar,
          email: String.upcase(user.email),
          username: user.username
        })

      assert "has already been taken" in errors_on(changeset_2).email
    end

    test "validates username uniqueness" do
      user = user_fixture()
      email = unique_user_email()

      {:error, changeset} =
        Accounts.register_user(%{avatar: user.avatar, email: email, username: user.username})

      assert "has already been taken" in errors_on(changeset).username
    end

    test "with valid avatar, email and username, registers users" do
      email = unique_user_email()
      username = unique_username()

      {:ok, user} =
        Accounts.register_user(%{
          avatar: "https://lh3.googleusercontent.com/a/anything",
          email: email,
          username: username
        })

      assert user.email == email
      assert user.username == username
    end
  end

  describe "generate_user_session_token/1" do
    test "generates a token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_user_session_token/1" do
    setup [:create_user_and_token]

    test "deletes the token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_user_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end

    test "deletes all tokens for the given user", %{user: user} do
      token = Accounts.generate_user_session_token(user)

      assert Accounts.clear_all_tokens_for_user(user) == :ok
      assert Accounts.get_user_by_session_token(token) == nil
    end
  end

  describe "list_users/1" do
    test "returns a list of all users when no filter is passed" do
      _users = create_multiple_users(5)
      all_users = Accounts.list_users()

      assert length(all_users) == 5
    end
  end

  test "returns an empty list when there are no users" do
    assert [] = Accounts.list_users()
  end

  test "returns only relevant users when searching" do
    _users = create_multiple_users(5)
    relevant_user = user_fixture(%{username: "dean"})
    users = Accounts.list_users(%{search: "Dean"})

    assert length(users) == 1
    only_user = Enum.at(users, 0)
    assert relevant_user.id == only_user.id
  end
end
