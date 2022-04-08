defmodule CampusChat.ChatService do

  require Logger

  alias CampusChat.{CampusQuery, ChatQuery, Repo, Room, UsersRoomsRoles, Role, Message}

  def create_dialog(first_id, second_id) do
    with true <- user_exist?(first_id) && user_exist?(second_id),
         {:ok, room} <- Repo.insert(%Room{name: "Dialog between #{first_id} and #{second_id}"}),
         %Role{} = role <- Repo.get_by(Role, name: "USER"),
         {:ok, _first_user_room} <- Repo.insert(%UsersRoomsRoles{user_id: first_id, room: room, role: role}),
         {:ok, _second_user_room} <- Repo.insert(%UsersRoomsRoles{user_id: second_id, room: room, role: role}) do
            {:ok, room}
    else
      false -> {:error, "User does not exists"}
      nil -> {:error, "No such role"}
      {:error, changeset} -> changeset
      _ -> Logger.error("Dialog wasn't created")
    end
  end

  def create_chat_group(creator_id, list_ids, group_name) do
    list_ids = List.delete(list_ids, creator_id)
    with true <- users_exists?(list_ids) && user_exist?(creator_id),
         {:ok, room} <- Repo.insert(%Room{name: group_name}),
         %Role{} = user_role <- Repo.get_by(Role, name: "USER"),
         %Role{} = admin_role <- Repo.get_by(Role, name: "ADMIN"),
         {:ok, _admin_room} <- Repo.insert(%UsersRoomsRoles{user_id: creator_id, room: room, role: admin_role}) do
            Enum.map(list_ids, fn id -> Repo.insert(%UsersRoomsRoles{user_id: id, room: room, role: user_role}) end)
            {:ok, room}
    else
      false -> {:error, "User does not exist"}
      nil -> {:error, "No such role"}
      {:error, changeset} -> changeset
      _ -> Logger.error("Chat wasn't created")
    end
  end

  def get_chats(user_id) do
    with true <- user_exist?(user_id) do
            ChatQuery.get_rooms_of_user(user_id)
    end
  end

  def get_messages(room_id) do
    ChatQuery.get_messages(room_id)
  end

  def preload_messages(start_message_id) do
    ChatQuery.preload_last_messages(start_message_id)
  end

  def save_message(%{sender_id: sender_id, room_id: room_id, text: text}) do
    with true <- user_exist?(sender_id),
         %Room{} = room <- Repo.get(Room, room_id),
         {:ok, message} <- Repo.insert(%Message{room: room, sender_id: sender_id, text: text}) do
           %{
              id:        message.id,
              sender_id: message.sender_id,
              text:      message.text,
              room_id:   message.room_id,
              room_name: room.name,
              time:      message.inserted_at
          }
    else
      false -> {:error, "Sender does not exist"}
      nil -> {:error, "Room does not exist"}
      _ -> Logger.error("Message wasn't saved")
    end
  end

  def change_room_name(admin_id, room_id, name) do
    with true <- user_exist?(admin_id),
         true <- room_exists?(room_id),
        {:ok, role} <- ChatQuery.get_authority(admin_id, room_id) do
          if role.name == "ADMIN" do
            room = Repo.get(Room, room_id)
            Repo.update(Ecto.Changeset.change(room, name: name))
          else
            {:error, "User does not have admin rights"}
          end
    else
      false -> {:error, "User or room does not exist"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp room_exists?(room_id) do
    case Repo.get(Room, room_id) do
      nil -> false
      _ -> true
    end
  end

  defp users_exists?(list_ids) do
    Enum.map(list_ids, fn id -> user_exist?(id) end) |> List.foldl(true, fn ex, acc -> ex && acc end)
  end

  defp user_exist?(id) do
    case CampusQuery.get_user_by_id(id) do
      nil -> false
      _   -> true
    end
  end
end
