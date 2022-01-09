defmodule CampusChat.Repo.Migrations.AddTestFiledToMessage do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      modify :text, :text
      add :test_field, :string, size: 500
    end
  end
end
