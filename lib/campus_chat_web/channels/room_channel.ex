defmodule CampusChatWeb.RoomChannel do
  use CampusChatWeb, :channel

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
    IO.puts("pong")
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
  def handle_in("new_msg", %{"id" => id, "body" => body}, socket) do
    IO.inspect(body)
    broadcast!(socket, "new_msg", %{id: id, body: body})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  # defp authorized?(_payload) do
  #   true
  # end
end
