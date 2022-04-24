defmodule CampusChatWeb.RoomChannel do
  use CampusChatWeb, :channel

  alias CampusChat.{ChatService}

  # @impl true
  # def join("room:lobby", payload, socket) do
  #   if authorized?(payload) do
  #     {:ok, socket}
  #   else
  #     {:error, %{reason: "unauthorized"}}
  #   end
  # end

  # @impl true
  # def join("room:lobby", _message, socket) do
  #   {:ok, socket}
  # end

  @impl true
  def join("room:" <> _room_id, _message, socket) do
    {:ok, socket}
  end

  @impl true
  def join("room:" <> "secret room", _message, socket) do
    {:reply, {:ok, %{answer: "Tssss"}}, socket}
  end

  # @impl true
  # def join("room:" <> _private_room_id, _params, _socket) do
  #   {:error, %{reason: "unauthorized"}}
  # end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_msg", %{"room_id" => room_id, "sender_id" => sender_id, "text" => text}, socket) do
    result = ChatService.save_message(sender_id, room_id, text)
    case result do
      {:ok, message} -> broadcast!(socket, "new_msg", message)
    end
    {:reply, result, socket}
  end

  # Add authorization logic here as required.
  # defp authorized?(_payload) do
  #   true
  # end
end
