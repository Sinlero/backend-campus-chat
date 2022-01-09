defmodule CampusChat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :chat_id, :integer
    field :date, :naive_datetime
    field :sender_id, :integer
    field :text, :string
    field :test_field, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:sender_id, :text, :chat_id, :date, :test_field])
    |> validate_required([:sender_id, :text, :chat_id, :date, :test_field])
  end
end
