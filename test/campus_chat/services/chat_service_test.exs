defmodule CampusChat.ChatServiceTest do
  use CampusChat.DataCase

  alias CampusChat.{ChatService, ChatQuery, Repo}

  import CampusChat.Fixtures

  defp create_room(name \\ "LIT") when is_binary(name) do
    ChatService.create_chat_group(valid_user().id, valid_ids_for_chat(), name)
  end

  test "create chat group" do
    ids = valid_ids_for_chat()
    {:ok, room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), ids, "LIT")
    saved = room |> ChatQuery.get_users_from_room() |> Enum.map(fn user -> user.id end)
    assert valid_ids_for_chat() == saved
  end

  test "create dialog two users" do
    {:ok, room} = ChatService.create_dialog(valid_user().id, valid_dialog_user_id())
    room |> Repo.preload(:users)
    ids = room |> ChatQuery.get_users_from_room() |> Enum.map(fn user -> user.id end)
    assert ids == [valid_user().id, valid_dialog_user_id()]
  end

  test "send message into dialog" do
    {:ok, room} = ChatService.create_dialog(valid_user().id, valid_dialog_user_id())
    message = ChatService.save_message(%{sender_id: valid_user().id, room_id: room.id, text: "Hello Alexey"})
    assert message.text == "Hello Alexey"
  end

  test "send message into chat room" do
    {:ok, room} = create_room()
    message = ChatService.save_message(%{sender_id: valid_user().id, room_id: room.id, text: "Hello All"})
    assert message.text == "Hello All"
  end

  test "get rooms of user" do
    {:ok, _room} = create_room("ROOM 1")
    {:ok, _room2} = create_room("ROOM 2")
    count_chats = ChatService.get_chats(valid_user().id) |> Enum.count()
    assert count_chats == 2
  end

  test "get messages from room" do
    {:ok, room} = create_room()
    message = %{room_id: room.id, sender_id: valid_user().id, text: "DEFAULT TEXT"}
    for _i <- 1..100 do
      ChatService.save_message(message)
    end
    assert ChatService.get_messages(room.id) |> Enum.count() == 30
  end

  test "change room name" do
    {:ok, room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), valid_ids_for_chat(), "QWeRTY")
    {:ok, changed} = ChatService.change_room_name(valid_user_id_for_chat_group(), room.id, "CHANGED ROOM NAME")
    assert changed.name == "CHANGED ROOM NAME"
  end

  test "change room name with no authority user" do
    {:ok, room} = ChatService.create_chat_group(valid_user_id_for_chat_group(), valid_ids_for_chat(), "QWeRTY")
    {:error, reason} = ChatService.change_room_name(valid_user().id, room.id, "CHANGED ROOM NAME")
    assert reason == "User does not have admin rights"
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
end
