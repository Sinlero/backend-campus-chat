defmodule CampusChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table("messages") do
      add :sender_id, :integer
      add :text, :text
      add :room_id, references("rooms")

      timestamps()
    end
  end
end
