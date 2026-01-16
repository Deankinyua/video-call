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

    create unique_index(:contacts, [:contact_user_id, :user_id])
  end
end
