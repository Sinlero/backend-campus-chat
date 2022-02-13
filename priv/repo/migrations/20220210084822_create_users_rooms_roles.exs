defmodule CampusChat.Repo.Migrations.CreateUsersRoomsRoles do
  use Ecto.Migration

  def change do
    create table("users_rooms_roles") do
      add :user_id, :integer
      add :room_id, references("rooms")
      add :role_id, references("roles")
    end
  end
end
