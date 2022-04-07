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

end
