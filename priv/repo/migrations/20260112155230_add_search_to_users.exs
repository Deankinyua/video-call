defmodule VideoCall.Repo.Migrations.AddSearchToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :search_vector, :tsvector
    end

    # Create GIN index for fast full-text search
    create index(:users, [:search_vector], using: :gin)

    # Create function to update search vector
    execute """
            CREATE OR REPLACE FUNCTION update_users_search_vector()
            RETURNS trigger AS $$
            BEGIN
              NEW.search_vector :=
                to_tsvector('english', COALESCE(NEW.username, ''));
              RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;
            """,
            """
            DROP FUNCTION IF EXISTS update_users_search_vector();
            """

    # Create trigger to automatically update search vector
    execute """
            CREATE TRIGGER update_users_search_vector_trigger
              BEFORE INSERT OR UPDATE ON users
              FOR EACH ROW EXECUTE FUNCTION update_users_search_vector();
            """,
            """
            DROP TRIGGER IF EXISTS update_users_search_vector_trigger ON users;
            """

    # Backfill existing users with search vectors
    execute """
            UPDATE users SET search_vector =
              to_tsvector('english', COALESCE(username, ''))
            """,
            ""
  end
end
