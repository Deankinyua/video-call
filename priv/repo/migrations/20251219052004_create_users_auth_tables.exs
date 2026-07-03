defmodule VideoCall.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :avatar, :string, null: false
      add :email, :citext, null: false
      add :username, :string, null: false

      timestamps()
    end

    # users cannnot share an email
    create unique_index(:users, [:email])

    # users cannnot share a username
    create unique_index(:users, [:username])

    create table(:users_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :context, :string, null: false
      add :token, :binary, null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(updated_at: false)
    end

    # this will make it much faster to search for tokens by using the user_id
    # see Accounts.clear_all_tokens_for_user/1
    create index(:users_tokens, [:user_id])

    # users cannot share the same combination of the context and the token
    create unique_index(:users_tokens, [:context, :token])
  end
end
