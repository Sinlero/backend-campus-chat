defmodule CampusChat.Repo.Migrations.CreateUsersRoomsRoles do
  use Ecto.Migration

  def change do
    create table("users_rooms_roles") do
      add :user_id, :bigint
      add :room_id, references("rooms")
      add :role_id, references("roles")
    end

    create index(:users_rooms_roles, [:user_id])
    create index(:users_rooms_roles, [:room_id])

  end
end
