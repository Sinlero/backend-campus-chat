defmodule CampusChat.CampusDbReadTest do
  use CampusChat.DataCase

  alias CampusChat.CampusRepo

  test "read user from campus by id" do
    id = 1652
    query = from user in "users",
              where: user.id == ^id,
              select: {user.id, user.name, user.surname, user.patronymic,
              user.login, user.password, user.description, user.course, user.group_name}
    assert [] != CampusRepo.all(query)
  end

  test "read all users" do
    query = from user in "users",
      select: {user.id, user.name, user.surname, user.patronymic,
      user.login, user.password, user.description, user.course, user.group_name}
    assert [] != CampusRepo.all(query)
  end

  test "get all categories" do
    query = from category in "category",
      select: {category.id, category.name, category.type}
    assert [] != CampusRepo.all(query)
  # IO.inspect(CampusRepo.all(query))
  end

  @doc """
  select * from users
    join users_categories on users.id = users_categories.user_id
        join category  on users_categories.category_id = category.id
  where category_id = 8
  """
  test "get users on selected category" do
    category_id = 8 # ФМФ
    query =
      from user in "users",
        join: user_category in "users_categories", on: user.id == user_category.user_id,
            join: category in "category", on: user_category.category_id == category.id,
              where: category.id == ^category_id,
                select: {category.name, user.id, user.name, user.surname, user.patronymic,
                        user.login, user.password, user.description, user.course, user.group_name}
    assert [] != CampusRepo.all(query)
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
  test "get list of groups and courses by category" do
    category_id = 8 # ФМФ
    query =
      from user in "users",
        join: user_category in "users_categories", on: user.id == user_category.user_id,
          join: category in "category", on: user_category.category_id == category.id,
            where: category.id == ^category_id ,
              group_by: [user.course, user.group_name],
                order_by: [user.group_name, user.course],
                  select: {user.course, user.group_name, count(user.course)}
    assert [] != CampusRepo.all(query)
  end

  @doc """
  select * from users
    join users_categories on users.id = users_categories.user_id
        join category  on users_categories.category_id = category.id
  where category_id = 8 and course = 4 and group_name = 'А'
  """
  test "get users on selected group" do
    category_id = 8 # ФМФ
    course = 4
    group = "А"
    query =
      from user in "users",
        join: user_category in "users_categories", on: user.id == user_category.user_id,
            join: category in "category", on: user_category.category_id == category.id,
              where: category.id == ^category_id and user.course == ^course and user.group_name == ^group,
                select: {category.name, user.id, user.name, user.surname, user.patronymic,
                        user.login, user.password, user.description, user.course, user.group_name}
    assert [] != CampusRepo.all(query)
  end
end
