defmodule CampusChat.ChatService do

  require Logger

  alias CampusChat.{CampusQuery, ChatQuery, Repo, Room, User, UsersRoomsRoles, Role, Message}

  def create_dialog(first_id, second_id) when is_integer(first_id)
                                          and is_integer(second_id) do
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

  def create_dialog(_first_id, _second_id) do
    wrong_input_data_type()
  end

  def create_chat_group(creator_id, list_ids, group_name) when is_integer(creator_id)
                                                           and is_list(list_ids)
                                                           and is_binary(group_name) do
    list_ids = clear_input_ids(creator_id, list_ids)
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

  def create_chat_group(_creator_id, _list_ids, _group_name) do
    wrong_input_data_type()
  end

  def add_users(admin_id, list_ids, room_id) when is_integer(admin_id)
                                              and is_list(list_ids)
                                              and is_integer(room_id) do
    list_ids = clear_input_ids(admin_id, list_ids)
    with {:ok, _user_id, room, _role} <- check_admin_authority(admin_id, room_id),
          true <- users_exists?(list_ids),
          %Role{} = user_role <- Repo.get_by(Role, name: "USER") do
            room_users_ids = ChatQuery.get_users_ids_from_room(room)
            Enum.map(list_ids, fn id -> if Enum.member?(room_users_ids, id) == false, do: Repo.insert(%UsersRoomsRoles{user_id: id, room: room, role: user_role}) end)
            {:ok, room}
    else
      false -> {:error, "User does not exist"}
      nil -> {:error, "No such role"}
      {:error, reason} -> {:error, reason}
    end
  end

  def add_users(_admin_id, _list_ids, _room_id) do
    wrong_input_data_type()
  end

  def delete_users(admin_id, list_ids, room_id) when is_integer(admin_id)
                                                and is_list(list_ids)
                                                and is_integer(room_id) do
    list_ids = clear_input_ids(admin_id, list_ids)
    with {:ok, _user_id, room, _role} <- check_admin_authority(admin_id, room_id),
          true <- users_exists?(list_ids) do
            room_users_ids = ChatQuery.get_users_ids_from_room(room)
            Enum.map(list_ids, fn id -> if Enum.member?(room_users_ids, id) == true, do: ChatQuery.delete_user_from_room(id, room) end)
            {:ok, room}
    else
      false -> {:error, "User does not exist"}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete_users(_admin_id, _list_ids, _room_id) do
    wrong_input_data_type()
  end

  def get_chats(user_id) when is_integer(user_id) do
    with true <- user_exist?(user_id) do
            rooms = ChatQuery.get_rooms_of_user(user_id)
            rooms = Enum.map(rooms, fn room -> %{id: room.id,
                                        name: room.name,
                                        users: Enum.map(ChatQuery.get_users_from_room(room), fn user -> User.transfer_cast(user) end),
                                        messages: ChatQuery.get_messages(room.id) |> format_messages()
                                        }
                                      end)
            {:ok, rooms}
    else
        false -> {:error, "User does not exist"}
        {:error, reason} -> {:error, reason}
    end
  end

  def get_chats(_user_id) do
    wrong_input_data_type()
  end

  defp format_messages(list) when is_nil(list) do
    nil
  end

  defp format_messages(list) when is_list(list) do
    Enum.map(list, fn msg -> Message.transfer_cast(msg) end)
  end

  def get_messages(room_id) when is_integer(room_id) do
    ChatQuery.get_messages(room_id)
  end

  def get_messages(_room_id) do
    wrong_input_data_type()
  end

  def preload_messages(room_id, start_message_id) when is_integer(start_message_id) do
    ChatQuery.preload_last_messages(room_id, start_message_id)
  end

  def preload_messages(_start_message_id) do
    wrong_input_data_type()
  end

  def save_message(sender_id, room_id, text) when is_integer(sender_id)
                                              and is_integer(room_id)
                                              and is_binary(text) do
    with true <- user_exist?(sender_id),
         {:ok, room} <- room_exists?(room_id),
         {:ok, message} <- Repo.insert(%Message{room: room, sender_id: sender_id, text: text}) do
           saved = %{
              id:        message.id,
              sender_id: message.sender_id,
              text:      message.text,
              room_id:   message.room_id,
              room_name: room.name,
              time:      message.inserted_at
          }
          {:ok, saved}
    else
      false -> {:error, "Sender or room does not exist"}
      _ -> Logger.error("Message wasn't saved")
    end
  end

  def save_message(_sender_id, _room_id, _text) do
    wrong_input_data_type()
  end

  def change_room_name(admin_id, room_id, name) when is_integer(admin_id)
                                                 and is_integer(room_id)
                                                 and is_binary(name) do
    with {:ok, _admin_id, room, _role} <- check_admin_authority(admin_id, room_id) do
            Repo.update(Ecto.Changeset.change(room, name: name))
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def change_room_name(_admin_id, _room_id, _name) do
    wrong_input_data_type()
  end

  def add_admin_role(admin_id, new_admins_ids, room_id) when is_integer(admin_id)
                                                         and is_list(new_admins_ids)
                                                         and is_integer(room_id) do
    new_admins_ids = clear_input_ids(admin_id, new_admins_ids)
    with {:ok, _admin_id, room, role} <- check_admin_authority(admin_id, room_id),
         true <- users_exists?(new_admins_ids) do
           Enum.map(new_admins_ids, fn id -> ChatQuery.update_role(id, role, room) end)
           {:ok, room}
    else
      false -> {:error, "User does not exist"}
      {:error, reason} -> {:error, reason}
    end
  end

  def add_admin_role(_admin_id, _new_admins_ids, _room_id) do
    wrong_input_data_type()
  end

  def remove_admin_role(admin_id, removed_ids, room_id) when is_integer(admin_id)
                                                           and is_list(removed_ids)
                                                           and is_integer(room_id) do
    removed_ids = clear_input_ids(admin_id, removed_ids)
    with {:ok, _admin_id, room, _role} <- check_admin_authority(admin_id, room_id),
         %Role{} = user_role <- Repo.get_by(Role, name: "USER"),
         true <- users_exists?(removed_ids) do
           Enum.map(removed_ids, fn id -> ChatQuery.update_role(id, user_role, room) end)
           {:ok, room}
    else
      false -> {:error, "User does not exist"}
      nil -> {:error, "No such role"}
      {:error, reason} -> {:error, reason}
    end
  end

  def remove_admin_role(_admin_id, _new_admins_ids, _room_id) do
    wrong_input_data_type()
  end

  defp check_admin_authority(user_id, room_id) do
    with true <- user_exist?(user_id),
         {:ok, room} <- room_exists?(room_id),
         {:ok, role} <- ChatQuery.get_authority(user_id, room.id),
         {:ok, "ADMIN"} <- Map.fetch(role, :name) do
           {:ok, user_id, room, role}
    else
      false -> {:error, "User or room does not exist"}
      {:ok, "USER"} -> {:error, "User have no admin authority"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp room_exists?(room_id) do
    case room = Repo.get(Room, room_id) do
      nil -> false
      _ -> {:ok, room}
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

  defp clear_input_ids(admin_id, list_id) do
    List.delete(list_id, admin_id) |> Enum.uniq()
  end

  defp wrong_input_data_type() do
    {:error, "Wrong input data types"}
  end
end
