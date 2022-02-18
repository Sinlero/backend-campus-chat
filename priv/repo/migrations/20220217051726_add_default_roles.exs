defmodule CampusChat.Repo.Migrations.AddDefaultRoles do
  use Ecto.Migration

  def change do
    execute "INSERT into roles(name) values ('ADMIN'),('USER')"
  end
end
