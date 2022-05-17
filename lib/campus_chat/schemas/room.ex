defmodule CampusChat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
      field :name, :string
      field :chat, :boolean
      has_many :messages, CampusChat.Message
      has_many :users, CampusChat.UsersRoomsRoles
  end

    @doc false
    def changeset(room, attrs) do
      room
      |> cast(attrs, [:name])
      |> validate_required([:name])
    end
end
