defmodule VideoCall.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query

  alias VideoCall.Accounts.User
  alias VideoCall.Accounts.UserToken
  alias VideoCall.Repo
  alias VideoCall.TextSearchHelpers

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type email :: String.t()
  @type filters :: map()
  @type id :: Ecto.UUID.t()
  @type token :: binary()
  @type user :: User.t()

  @doc """
  Returns a list of users filtered by the given filters.

   ## Examples

      iex> list_users(%{search: "John"})
      [%User{}, ...]
  """
  @spec list_users(filters()) :: [user()]
  def list_users(filters \\ %{}) do
    filter_query = apply_filters()

    user_query()
    |> where(^filter_query.(filters))
    |> limit(12)
    |> TextSearchHelpers.apply_search_ordering(filters[:search])
    |> Repo.all()
  end

  defp user_query do
    from user in User, as: :user
  end

  defp apply_filters do
    fn filters ->
      Enum.reduce(filters, dynamic(true), &apply_filter/2)
    end
  end

  defp apply_filter({:current_user_id, current_user_id}, dynamic) do
    dynamic([user: user], ^dynamic and user.id != ^current_user_id)
  end

  defp apply_filter({:search, search_query}, dynamic),
    do: TextSearchHelpers.apply_filter({:search, search_query}, dynamic)

  defp apply_filter(_other, dynamic), do: dynamic

  @spec get_or_create_user(attrs()) :: {:ok, user()} | {:error, changeset()}
  def get_or_create_user(%{email: email} = user) do
    case get_user_by_email(email) do
      nil ->
        register_user(user)

      user ->
        {:ok, user}
    end
  end

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  @spec get_user_by_email(email()) :: user() | nil
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(id()) :: user() | nil
  def get_user!(id), do: Repo.get(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec register_user(attrs()) :: {:ok, user()} | {:error, changeset()}
  def register_user(attrs \\ %{}) do
    %User{}
    |> change_user(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user(user(), attrs()) :: changeset()
  def change_user(%User{} = user, attrs \\ %{}) do
    User.user_changeset(user, attrs)
  end

  @doc """
  Generates a session token.
  """
  @spec generate_user_session_token(user()) :: token()
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  @spec get_user_by_session_token(token()) :: user() | nil
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  @spec delete_user_session_token(token()) :: :ok
  def delete_user_session_token(token) do
    query = UserToken.token_and_context_query(token, "session")
    Repo.delete_all(query)

    :ok
  end

  @doc """
  Deletes all remaining tokens from db that belong to user.
  It will be called when logging in to ensure all tokens are deleted before we create a new one

  ## Examples

      iex> clear_all_tokens_for_user(%ElixirDrops.Accounts.User{})
      :ok

  """
  @spec clear_all_tokens_for_user(user()) :: :ok
  def clear_all_tokens_for_user(user) do
    q = UserToken.user_and_contexts_query(user, :all)
    Repo.delete_all(q)
    :ok
  end
end
