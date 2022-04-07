defmodule CampusChat.Repo.Migrations.CreateUsersTokens do
  use Ecto.Migration

  def change do

    create table("users_tokens") do
      add :user_id, :integer
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

  end
end
