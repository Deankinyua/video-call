defmodule VideoCall.AccountsTest do
  use VideoCall.DataCase, async: true

  import VideoCall.AccountsFixtures

  alias VideoCall.Accounts
  alias VideoCall.Accounts.User
  alias VideoCall.Accounts.UserToken

  defp create_user_and_token(_attrs) do
    user = user_fixture()
    token = Accounts.generate_user_session_token(user)
    %{user: user, token: token}
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

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      _user = user_fixture(%{email: "deankinyua@gmail.com"})
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "helloworldkenya")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture(%{email: "deankinyua@gmail.com", password: "johndoesoftwaredev"})
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      user = user_fixture(%{email: "deankinyua@gmail.com", password: "johndoesoftwaredev"})

      assert Accounts.get_user_by_email_and_password(user.email, "johndoesoftwaredev")
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
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      very_long_string = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.register_user(%{email: very_long_string, password: very_long_string})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      user = user_fixture()

      {:error, changeset} = Accounts.register_user(%{email: user.email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset_2} = Accounts.register_user(%{email: String.upcase(user.email)})
      assert "has already been taken" in errors_on(changeset_2).email
    end

    test "registers users with a hashed password" do
      email = unique_user_email()
      username = unique_username()

      {:ok, user} =
        Accounts.register_user(%{email: email, password: "hello world kenya", username: username})

      assert user.email == email
      assert user.username == username
      assert is_binary(user.hashed_password)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = _changeset = Accounts.change_user_registration(%User{})
    end

    test "allows fields to be set" do
      email = unique_user_email()
      username = unique_username()
      password = "helloworldkenya"

      changeset =
        Accounts.change_user_registration(
          %User{},
          %{email: email, password: password, username: username}
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert get_change(changeset, :username) == username
      assert is_nil(get_change(changeset, :hashed_password))
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

    test "deletes the token", %{token: token} do
      assert Accounts.delete_user_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end
end
