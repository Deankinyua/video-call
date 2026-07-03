defmodule VideoCall.Repo.Migrations.Contacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :contact_user_id, references(:users, on_delete: :delete_all, type: :binary_id),
        null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create unique_index(:contacts, [:user_id, :contact_user_id])

    # since we've created a multicolumn index above with the user_id being the
    # leftmost column we don't need to do:
    # * create index(:contacts, [:user_id])
    # PG will use the above multicolumn index to speed up WHERE clauses involving :user_id
    # such as queries that will be used to retrieve all contacts belonging to
    # a specific user

    # So in short look at what kind of queries you would be making and mutate
    # the order of the columns in your multicolumn index
  end
end
