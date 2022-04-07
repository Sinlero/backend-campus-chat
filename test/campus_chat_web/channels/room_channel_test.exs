defmodule CampusChatWeb.RoomChannelTest do
  use CampusChatWeb.ChannelCase

  import CampusChat.Fixtures

  setup do
    {:ok, _, socket} =
      CampusChatWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(CampusChatWeb.RoomChannel, "room:lobby")

    %{socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to room:lobby", %{socket: socket} do
    push socket, "shout", %{"hello" => "all"}
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

  test "send message to room:lobby", %{socket: socket} do
    message = %{"room_id" => 1, "sender_id" => valid_user_id_for_chat_group(), "text" => "Hello world"}
    push socket, "new_msg", message
    assert_broadcast "new_msg", ^message
  end
end
