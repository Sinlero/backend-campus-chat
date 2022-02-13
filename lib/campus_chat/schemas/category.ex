defmodule CampusChat.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "category" do
    field :name,      :string
    field :type,      :string
    field :remote_id, :integer
    many_to_many :users, CampusChat.User, join_through: "users_categories"
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :type, :remote_id])
    |> validate_required([:name, :type])
  end
end
