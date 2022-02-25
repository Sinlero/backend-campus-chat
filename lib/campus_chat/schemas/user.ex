defmodule CampusChat.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key{:id, :id, autogenerate: false}
  schema "users" do
    field :name,        :string
    field :surname,     :string
    field :patronymic,  :string
    field :login,       :string
    field :password,    :string
    field :description, :string
    field :course,      :integer
    field :group_name,  :string
    field :active,      :boolean
    field :archival,    :boolean
    field :valid_photo, :boolean
    field :photo,       :string
    many_to_many :categories, CampusChat.Category, join_through: "users_categories"
  end

    @doc false
    def changeset(user, attrs) do
      user
      |> cast(attrs, [:name, :surname, :patronymic, :login, :password, :description, :course, :group_name])
      |> validate_required([:name, :surname, :patronymic, :login, :password, :description, :course, :group_name])
    end
end
