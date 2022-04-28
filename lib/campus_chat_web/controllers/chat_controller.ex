defmodule CampusChatWeb.ChatController do
  use Phoenix.Controller

  alias CampusChat.ChatService

  def dialog(conn, %{"first" => first_id, "second" => second_id}) do
    result = ChatService.create_dialog(first_id, second_id)
    case result do
      {:ok, room}     -> json(conn, %{id: room.id})  |> halt()
      {:error, error} -> send_resp(conn, 404, error) |> halt()
    end
  end

  def group(conn, %{"id" => creator_id, "users" => list_ids, "name" => group_name}) do
    result = ChatService.create_chat_group(creator_id, list_ids, group_name)
    case result do
      {:ok, room}     -> json(conn, %{id: room.id})  |> halt()
      {:error, error} -> send_resp(conn, 404, error) |> halt()
    end
  end

  def rooms(conn, _params) do
    %{current_user: user} = conn.assigns
    result = ChatService.get_chats(user.id)
    case result do
      {:ok, rooms} -> json(conn, rooms) |> halt()
      {:error, error} -> send_resp(conn, 404, error) |> halt()
    end
  end

end
