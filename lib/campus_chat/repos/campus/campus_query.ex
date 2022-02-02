defmodule CampusChat.CampusQuery do

  import Ecto.Query
  alias CampusChat.CampusRepo
  alias CampusChat.User

  @spec getUserById(integer) :: struct
  def getUserById(id) do

    query = from user in "users",
              where: user.id == ^id,
              select: {user.id, user.name, user.surname, user.patronymic,
              user.login, user.password, user.description, user.course, user.group_name}

    CampusRepo.one(query)
    |> User.new()
  end

  @spec getAllUsers :: list(struct)
  def getAllUsers() do
    query = from user in "users",
      select: {user.id, user.name, user.surname, user.patronymic,
      user.login, user.password, user.description, user.course, user.group_name}

    CampusRepo.all(query)
  end

  @spec getAllCategories :: list(struct)
  @doc """
  ФМФ, ИФФ, Сотрудники и т.д.
  """
  def getAllCategories() do
    query = from category in "category",
            select: {category.id, category.name, category.type}

    CampusRepo.all(query)
  end

  @spec getUsersByCategory(any) :: any
  @doc """
  select * from users
    join users_categories on users.id = users_categories.user_id
        join category  on users_categories.category_id = category.id
  where category_id = 8
  """
  def getUsersByCategory(category_id) do
    query =
      from user in "users",
        join: user_category in "users_categories", on: user.id == user_category.user_id,
            join: category in "category", on: user_category.category_id == category.id,
              where: category.id == ^category_id,
                select: {category.name, user.id, user.name, user.surname, user.patronymic,
                        user.login, user.password, user.description, user.course, user.group_name}
    CampusRepo.all(query)
  end

  @spec getUsersByGroup(integer, integer, String.t()) :: any
  @doc """
  select * from users
    join users_categories on users.id = users_categories.user_id
        join category  on users_categories.category_id = category.id
  where category_id = 8 and course = 4 and group_name = 'А'
  """
  def getUsersByGroup(category_id, course, group) do
    query =
      from user in "users",
        join: user_category in "users_categories", on: user.id == user_category.user_id,
            join: category in "category", on: user_category.category_id == category.id,
              where: category.id == ^category_id and user.course == ^course and user.group_name == ^group,
                select: {category.name, user.id, user.name, user.surname, user.patronymic,
                        user.login, user.password, user.description, user.course, user.group_name}

    CampusRepo.all(query)
  end

  @doc """
  select course, group_name, count(course)
  from users
    join users_categories on users.id = users_categories.user_id
        join category  on users_categories.category_id = category.id
  where category_id = 8
  group by course, group_name
  order by group_name, course
  """
  def getListOfGroupsAndCourses(category_id) do
    query =
      from user in "users",
        join: user_category in "users_categories", on: user.id == user_category.user_id,
          join: category in "category", on: user_category.category_id == category.id,
            where: category.id == ^category_id ,
              group_by: [user.course, user.group_name],
                order_by: [user.group_name, user.course],
                  select: {user.course, user.group_name, count(user.course)}

    CampusRepo.all(query)
  end

end
