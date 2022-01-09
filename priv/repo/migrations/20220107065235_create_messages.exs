defmodule CampusChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :sender_id, :integer
      add :text, :string
      add :chat_id, :integer
      add :date, :naive_datetime

      timestamps()
    end
  end
end
