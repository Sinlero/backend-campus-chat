defmodule CampusChat.ChatQuery do

  import Ecto.Query

  alias CampusChat.{Repo, CampusQuery, UsersRoomsRoles, Room, Message, Role}

  @spec update_role(
          integer(),
          %Role{},
          %Room{}
        ) :: any
  def update_role(user_id, role, room) do
    from(record in UsersRoomsRoles, where: record.user_id == ^user_id and record.room_id == ^room.id)
    |> Repo.update_all(set: [role_id: role.id])
  end

  def get_rooms_of_user(user_id) do
    from(record in UsersRoomsRoles, where: record.user_id == ^user_id )
    |> Repo.all()
    |> Repo.preload(:room)
    |> Enum.map(fn record -> record.room end)
  end

  def get_messages(room_id) do
    {:ok, messages} = Repo.get(Room, room_id) |> Repo.preload(:messages) |> Map.fetch(:messages)
    if Enum.empty?(messages) do
      nil
    else
      last_message = messages |> Enum.max_by(fn message -> message.id end)
      preload_last_messages(room_id, last_message.id)
    end
  end

  def preload_last_messages(room_id, message_id) do
    from(msg in Message, where: msg.id <= ^message_id and msg.room_id == ^room_id, limit: 30, order_by: [desc: msg.id]) |> Repo.all()
  end

  def get_authority(user_id, room_id) do
    try do
      from(record in UsersRoomsRoles, where: record.user_id == ^user_id and record.room_id == ^room_id)
      |> Repo.one()
      |> Repo.preload(:role)
      |> Map.fetch(:role)
    rescue
      _e in BadMapError -> {:error, "User have no authorities in room"}
    end

  end

  def get_users_from_room(room) do
    ids = get_users_ids_from_room(room)
    Enum.map(ids, fn id -> CampusQuery.get_user_by_id(id) end)
  end

  def get_users_ids_from_room(room) do
    users_list = room |> Repo.preload(:users) |> Map.get(:users)
    Enum.map(users_list, fn user -> user.user_id end)
  end

  def delete_user_from_room(user_id, room) do
    from(record in UsersRoomsRoles, where: record.user_id == ^user_id and record.room_id == ^room.id)
    |> Repo.one()
    |> Repo.delete()
  end

end
