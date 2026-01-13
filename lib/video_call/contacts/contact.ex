defmodule VideoCall.Contacts.Contact do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias VideoCall.Accounts.User

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    belongs_to :contact_user, User
    belongs_to :user, User

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:contact_user_id, :user_id])
    |> unique_constraint([:contact_user_id, :user_id],
      message: "You already saved this contact"
    )
    |> validate_required([:contact_user_id, :user_id])
  end
end
