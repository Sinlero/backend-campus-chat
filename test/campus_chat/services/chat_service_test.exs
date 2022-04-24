defmodule CampusChat.ChatServiceTest do
  use CampusChat.DataCase

  alias CampusChat.{ChatService, ChatQuery, Repo}

  import CampusChat.Fixtures

  defp create_room(name \\ "LIT") when is_binary(name) do
    ChatService.create_chat_group(valid_user().id, valid_ids_for_chat(), name)
  end

  defp create_room(creator_id, list_ids, name) when is_binary(name) do
    ChatService.create_chat_group(creator_id, list_ids, name)
  end

# -------------------------- Chat groups tests ------------------------------------

  test "create chat group" do
    {:ok, room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), valid_ids_for_chat(), "LIT")
    saved = room |> ChatQuery.get_users_from_room() |> Enum.map(fn user -> user.id end)
    assert valid_ids_for_chat() == saved
  end

  test "create chat group with unexisted user" do
    {:error, reason} = ChatService.create_chat_group(valid_user_id_for_chat_group(), [-31254 | valid_ids_for_chat()], "QWeRTY")
    assert reason == "User does not exist"
  end

  test "create chat group with wrong creator id type" do
    {:error, reason} = ChatService.create_chat_group(Integer.to_string(valid_user().id), valid_ids_for_chat(), "QWeRTY")
    assert reason == "Wrong input data types"
  end

  test "create chat group with wrong users ids type" do
    {:error, reason} = ChatService.create_chat_group(valid_user().id, {valid_user_id_for_chat_group(), valid_dialog_user_id()}, "QWeRTY")
    assert reason == "Wrong input data types"
  end

  test "create chat group with wrong chat name type" do
    {:error, reason} = ChatService.create_chat_group(Integer.to_string(valid_user().id), valid_ids_for_chat(), 47234)
    assert reason == "Wrong input data types"
  end

  # -------------------------- Dialogs tests ------------------------------------

  test "create dialog two users" do
    {:ok, room} = ChatService.create_dialog(valid_user().id, valid_dialog_user_id())
    room |> Repo.preload(:users)
    ids = room |> ChatQuery.get_users_from_room() |> Enum.map(fn user -> user.id end)
    assert ids == [valid_user().id, valid_dialog_user_id()]
  end

  test "create dialog with unexisted user" do
    {:error, reason} = ChatService.create_dialog(-245634, valid_dialog_user_id())
    assert reason == "User does not exists"
  end

  test "create dialog with wrong args type" do
    {:error, reason} = ChatService.create_dialog(Integer.to_string(valid_user().id), [valid_dialog_user_id()])
    assert reason == "Wrong input data types"
  end

  # -------------------------- Save message tests ------------------------------------

  test "send message into dialog" do
    {:ok, room} = ChatService.create_dialog(valid_user().id, valid_dialog_user_id())
    {:ok, message} = ChatService.save_message(valid_user().id, room.id, "Hello Alexey")
    assert message.text == "Hello Alexey"
  end

  test "send message into dialog with unexisted user" do
    {:ok, room} = ChatService.create_dialog(valid_user().id, valid_dialog_user_id())
    {:error, reason} = ChatService.save_message(-123123, room.id, "Hello Alexey")
    assert reason == "Sender or room does not exist"
  end

  test "send message into dialog with unexisted room" do
    {:ok, _room} = ChatService.create_dialog(valid_user().id, valid_dialog_user_id())
    {:error, reason} = ChatService.save_message(valid_user().id, -123445, "Hello Alexey")
    assert reason == "Sender or room does not exist"
  end

  test "send message into chat room" do
    {:ok, room} = create_room()
    {:ok, message} = ChatService.save_message(valid_user().id, room.id, "Hello All")
    assert message.text == "Hello All"
  end

  test "send message with wrong sender id type" do
    {:ok, room} = create_room()
    {:error, reason} = ChatService.save_message(Integer.to_string(valid_user().id), room.id, "Hello All")
    assert reason == "Wrong input data types"
  end

  test "send message with wrong room id type" do
    {:ok, room} = create_room()
    {:error, reason} = ChatService.save_message(valid_user().id, Integer.to_string(room.id), "Hello All")
    assert reason == "Wrong input data types"
  end

  test "send message with wrong text type" do
    {:ok, room} = create_room()
    {:error, reason} = ChatService.save_message(valid_user().id, room.id, 25753768)
    assert reason == "Wrong input data types"
  end

  test "send message with multiply wrong types" do
    {:ok, room} = create_room()
    {:error, reason} = ChatService.save_message(Integer.to_string(valid_user().id), room.id, [123, "235", "dfgs"])
    assert reason == "Wrong input data types"
  end

  # -------------------------- Get chats tests ------------------------------------

  test "get rooms of user" do
    {:ok, _room} = create_room("ROOM 1")
    {:ok, _room2} = create_room("ROOM 2")
    count_chats = ChatService.get_chats(valid_user().id) |> Enum.count()
    assert count_chats == 2
  end

  test "get rooms of user with wrong user id type" do
    {:ok, _room} = create_room("ROOM 1")
    {:ok, _room2} = create_room("ROOM 2")
    {:error, reason} = ChatService.get_chats(Integer.to_string(valid_user().id))
    assert reason == "Wrong input data types"
  end

  # -------------------------- Get messages tests ------------------------------------

  test "get messages from room" do
    {:ok, room} = create_room()
    for _i <- 1..100 do
      ChatService.save_message(valid_user().id, room.id, "DEFAULT TEXT")
    end
    assert ChatService.get_messages(room.id) |> Enum.count() == 30
  end

  test "get messages from room with wrong room id type" do
    {:ok, room} = create_room()
    for _i <- 1..100 do
      ChatService.save_message(valid_user().id, room.id, "DEFAULT TEXT")
    end
    {:error, reason} = ChatService.get_messages(Integer.to_string(room.id))
    assert reason == "Wrong input data types"
  end

  # -------------------------- Change chat group name tests ------------------------------------

  test "change room name" do
    {:ok, room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), valid_ids_for_chat(), "QWeRTY")
    {:ok, changed} = ChatService.change_room_name(valid_user_id_for_chat_group(), room.id, "CHANGED ROOM NAME")
    assert changed.name == "CHANGED ROOM NAME"
  end

  test "change room name with no authority user" do
    {:ok, room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), valid_ids_for_chat(), "QWeRTY")
    {:error, reason} = ChatService.change_room_name(valid_user().id, room.id, "CHANGED ROOM NAME")
    assert reason == "User have no admin authority"
  end

  test "change room on unexisted room" do
    {:ok, _room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), valid_ids_for_chat(), "QWeRTY")
    {:error, reason} = ChatService.change_room_name(valid_user_id_for_chat_group(), -1413431, "CHANGED ROOM NAME")
    assert reason == "User or room does not exist"
  end

  test "change room name with unexisted user" do
    {:ok, room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), valid_ids_for_chat(), "QWeRTY")
    {:error, reason} = ChatService.change_room_name(-123123, room.id, "CHANGED ROOM NAME")
    assert reason == "User or room does not exist"
  end

  test "change room name with wrong admin id type" do
    {:ok, room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), valid_ids_for_chat(), "QWeRTY")
    {:error, reason} = ChatService.change_room_name(Integer.to_string(valid_user_id_for_chat_group()), room.id, "CHANGED ROOM NAME")
    assert reason == "Wrong input data types"
  end

  test "change room name with wrong room id type" do
    {:ok, room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), valid_ids_for_chat(), "QWeRTY")
    {:error, reason} = ChatService.change_room_name(valid_user_id_for_chat_group(), Integer.to_string(room.id), "CHANGED ROOM NAME")
    assert reason == "Wrong input data types"
  end

  test "change room name with wrong chat name type" do
    {:ok, room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), valid_ids_for_chat(), "QWeRTY")
    {:error, reason} = ChatService.change_room_name(valid_user_id_for_chat_group(), room.id, ["Changed", "room", "name"])
    assert reason == "Wrong input data types"
  end

  test "change room name with multiply wrong args type" do
    {:ok, room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), valid_ids_for_chat(), "QWeRTY")
    {:error, reason} = ChatService.change_room_name(Integer.to_string(valid_user_id_for_chat_group()), Integer.to_string(room.id), 2346)
    assert reason == "Wrong input data types"
  end

  # -------------------------- Add admin authorities tests ------------------------------------

  test "add admin authorites" do
    {:ok, room} = create_room()
    {:ok, _result} = ChatService.add_admin_role(valid_user().id, valid_ids_for_chat(), room.id)
    all_admins? = Repo.get(CampusChat.Room, room.id)
    |> Repo.preload(:users)
    |> Map.get(:users)
    |> Enum.reduce(true, fn usr, acc -> if(usr.role_id != 1, do: false, else: acc) end)
    assert all_admins? == true
  end

  test "add admin roles with user without authorities" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.add_admin_role(valid_dialog_user_id(), valid_ids_for_chat(), room.id)
    assert result == "User have no admin authority"
  end

  test "add admin authorites to unexisted room" do
    {:ok, _room} = create_room()
    {:error, result} = ChatService.add_admin_role(valid_user().id, valid_ids_for_chat(), -213)
    assert result == "User or room does not exist"
  end

  test "add admin roles with unexisted admin user" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.add_admin_role(-123, valid_ids_for_chat(), room.id)
    assert result == "User or room does not exist"
  end

  test "add admin roles with unexisted users" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.add_admin_role(valid_user().id, [-123, valid_user_id_for_chat_group()], room.id)
    assert result == "User does not exist"
  end

  test "add admin roles with wrong admin id type" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.add_admin_role(Integer.to_string(valid_user().id), valid_ids_for_chat(), room.id)
    assert result == "Wrong input data types"
  end

  test "add admin roles with wrong room id type" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.add_admin_role(valid_user().id, valid_ids_for_chat(), Integer.to_string(room.id))
    assert result == "Wrong input data types"
  end

  test "add admin roles with wrong users ids type" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.add_admin_role(valid_user().id, {valid_dialog_user_id(), valid_user_id_for_chat_group()}, room.id)
    assert result == "Wrong input data types"
  end

  test "add admin roles with multiply wrong args types" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.add_admin_role(Integer.to_string(valid_user().id), {valid_dialog_user_id(), valid_user_id_for_chat_group()}, room.id)
    assert result == "Wrong input data types"
  end

  # -------------------------- Remove admin authorities tests ------------------------------------

  def create_room_with_admins() do
    {:ok, room} = create_room()
    ChatService.add_admin_role(valid_user().id, valid_ids_for_chat(), room.id)
  end

  test "remove admin authorites" do
    {:ok, room} = create_room_with_admins()
    {:ok, result} = ChatService.remove_admin_role(valid_user().id, valid_ids_for_chat(), room.id)
    count_users = result |> Repo.preload(:users) |> Map.get(:users) |> Enum.reduce(0, fn usr, acc -> if(usr.role_id == 2, do: acc + 1, else: acc) end)
    assert count_users == 2
  end

  test "remove admin roles with user without authorities" do
    {:ok, room} = create_room_with_admins()
    ChatService.add_users(valid_user().id, [1990], room.id)
    {:error, result} = ChatService.remove_admin_role(1990, valid_ids_for_chat(), room.id)
    assert result == "User have no admin authority"
  end

  test "remove admin authorites to unexisted room" do
    {:ok, _room} = create_room_with_admins()
    {:error, result} = ChatService.remove_admin_role(valid_user().id, valid_ids_for_chat(), -213)
    assert result == "User or room does not exist"
  end

  test "remove admin roles with unexisted admin user" do
    {:ok, room} = create_room_with_admins()
    {:error, result} = ChatService.remove_admin_role(-123, valid_ids_for_chat(), room.id)
    assert result == "User or room does not exist"
  end

  test "remove admin roles with unexisted users" do
    {:ok, room} = create_room_with_admins()
    {:error, result} = ChatService.remove_admin_role(valid_user().id, [-123, valid_user_id_for_chat_group()], room.id)
    assert result == "User does not exist"
  end

  test "remove admin roles with wrong admin id type" do
    {:ok, room} = create_room_with_admins()
    {:error, result} = ChatService.remove_admin_role(Integer.to_string(valid_user().id), valid_ids_for_chat(), room.id)
    assert result == "Wrong input data types"
  end

  test "remove admin roles with wrong room id type" do
    {:ok, room} = create_room_with_admins()
    {:error, result} = ChatService.remove_admin_role(valid_user().id, valid_ids_for_chat(), Integer.to_string(room.id))
    assert result == "Wrong input data types"
  end

  test "remove admin roles with wrong users ids type" do
    {:ok, room} = create_room_with_admins()
    {:error, result} = ChatService.remove_admin_role(valid_user().id, {valid_dialog_user_id(), valid_user_id_for_chat_group()}, room.id)
    assert result == "Wrong input data types"
  end

  test "remove admin roles with multiply wrong args types" do
    {:ok, room} = create_room_with_admins()
    {:error, result} = ChatService.remove_admin_role(Integer.to_string(valid_user().id), {valid_dialog_user_id(), valid_user_id_for_chat_group()}, room.id)
    assert result == "Wrong input data types"
  end

  # -------------------------- Add users to chat tests ------------------------------------

  test "add users to group" do
    {:ok, room} = create_room()
    added_users_ids = [1899, 1990]
    {:ok, updated} = ChatService.add_users(valid_user().id, added_users_ids, room.id)
    room_ids = ChatQuery.get_users_ids_from_room(updated)
    assert Enum.all?(added_users_ids, fn id -> id in room_ids end) == true
  end

  test "add users to group (users can be in room already)" do
    {:ok, room} = create_room()
    {:ok, updated} = ChatService.add_users(valid_user().id, valid_ids_for_chat(), room.id)
    uniq? = ChatQuery.get_users_ids_from_room(updated)
    |> Enum.frequencies
    |> Enum.map(fn {_k,v} ->  if v == 1, do: true, else: false  end)
    |> Enum.all?()
    assert uniq? == true
  end

  test "add users with wrong admin id type" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.add_users(Integer.to_string(valid_user().id), [1990, 1899], room.id)
    assert result == "Wrong input data types"
  end

  test "add users with wrong list ids type" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.add_users(valid_user().id, {1990, 1899}, room.id)
    assert result == "Wrong input data types"
  end

  test "add users with wrong room id type" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.add_users(valid_user().id, [1990, 1899], Integer.to_string(room.id))
    assert result == "Wrong input data types"
  end

  test "add users with all wrong args type" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.add_users(Integer.to_string(valid_user().id), {1990, 1899}, Integer.to_string(room.id))
    assert result == "Wrong input data types"
  end

  # ------------------------------------ Delete users from chat group --------------------------------------------

  test "delete user" do
    {:ok, room} = create_room()
    ChatQuery.delete_user_from_room(valid_user_id_for_chat_group(), room)
    ids = ChatQuery.get_users_ids_from_room(room)
    assert Enum.member?(ids, valid_user_id_for_chat_group()) == false
  end

  test "delete users" do
    {:ok, room} = create_room()
    {:ok, updated} = ChatService.delete_users(valid_user().id, valid_ids_for_chat(), room.id)
    room_ids = ChatQuery.get_users_ids_from_room(updated)
    assert room_ids == [valid_user().id]
  end

  test "delete users with wrong admin id type" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.delete_users(Integer.to_string(valid_user().id), [1990, 1899], room.id)
    assert result == "Wrong input data types"
  end

  test "delete users with wrong list ids type" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.delete_users(valid_user().id, {1990, 1899}, room.id)
    assert result == "Wrong input data types"
  end

  test "delete users with wrong room id type" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.delete_users(valid_user().id, [1990, 1899], Integer.to_string(room.id))
    assert result == "Wrong input data types"
  end

  test "delete users with all wrong args type" do
    {:ok, room} = create_room()
    {:error, result} = ChatService.delete_users(Integer.to_string(valid_user().id), {1990, 1899}, Integer.to_string(room.id))
    assert result == "Wrong input data types"
  end

end
