defmodule CampusChat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
      field :name, :string
      has_many :messages, CampusChat.Message
      many_to_many :roles, CampusChat.Role, join_through: "users_rooms_roles"
  end

    @doc false
    def changeset(room, attrs) do
      room
      |> cast(attrs, [:name])
      |> validate_required([:name])
    end
end
