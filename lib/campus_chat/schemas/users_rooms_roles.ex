defmodule CampusChat.UsersRoomsRoles do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users_rooms_roles" do
    field :user_id, :integer
    belongs_to :room, CampusChat.Room, foreign_key: :room_id
    belongs_to :role, CampusChat.Role, foreign_key: :role_id
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end
end
