defmodule CampusChat.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :name, :string
    many_to_many :rooms, CampusChat.Room, join_through: "users_rooms_roles"
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end
