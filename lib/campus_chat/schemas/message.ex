defmodule CampusChat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :sender_id, :integer
    belongs_to :room, CampusChat.Room
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:sender_id, :text])
    |> validate_required([:sender_id, :text])
  end

  def transfer_cast(message) do
    %{
      id: message.id,
      sender_id: message.sender_id,
      text: message.text,
      time: message.inserted_at
    }
  end

end
