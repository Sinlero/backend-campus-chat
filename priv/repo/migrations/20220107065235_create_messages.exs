defmodule CampusChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table("messages") do
      add :sender_id, :bigint
      add :text, :text
      add :room_id, references("rooms")

      timestamps()
    end

    create index(:messages, [:sender_id])
    create index(:messages, [:room_id])

  end
end
