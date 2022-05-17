defmodule CampusChat.Repo.Migrations.CreateRoom do
  use Ecto.Migration

  def change do
    create table("rooms") do
      add :name, :string
      add :chat, :boolean
    end
  end
end
