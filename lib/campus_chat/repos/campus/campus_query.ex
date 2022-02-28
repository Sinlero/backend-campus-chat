defmodule CampusChat.CampusQuery do

  import Ecto.Query
  alias CampusChat.CampusRepo
  alias CampusChat.User
  alias CampusChat.Category

  def get_user_by_id(id) do
    CampusRepo.get(User, id)
  end

  def get_user_by_login_and_password(login, password) do
    from(user in User, where: user.login == ^login and user.password == ^password)
    |> CampusRepo.one()
  end

  def get_user_by_id_with_categories(id) do
    get_user_by_id(id)
    |> CampusRepo.preload([:categories])
  end

  def get_all_users() do
    query = from user in User,
            select: user
    CampusRepo.all(query)
  end

  def get_category_by_id(category_id) do
    CampusRepo.get(Category, category_id)
  end

  @doc """
  ФМФ, ИФФ, Сотрудники и т.д.
  """
  def get_all_categories() do
    query = from category in Category,
            select: category
    CampusRepo.all(query)
  end

  @doc """
  select * from users
    join users_categories on users.id = users_categories.user_id
        join category  on users_categories.category_id = category.id
  where category_id = 8
  """
  def get_users_by_category(category_id) do
    get_category_by_id(category_id)
    |> CampusRepo.preload(:users)
  end

  @doc """
  select * from users
    join users_categories on users.id = users_categories.user_id
        join category  on users_categories.category_id = category.id
  where category_id = 8 and course = 4 and group_name = 'А' and users.archival = false
  """
  def get_users_by_group(category_id, course, group) do
    CampusRepo.get(Category, category_id)
    |> CampusRepo.preload([users: from(u in User, where: u.course == ^course and u.group_name == ^group and u.archival == false)])
  end

  @doc """
  select course, group_name, count(course)
  from users
    join users_categories on users.id = users_categories.user_id
        join category  on users_categories.category_id = category.id
  where category_id = 8 and users.archival = false
  group by course, group_name
  order by group_name, course
  """
  def get_list_of_groups_and_courses(category_id) do
    query = from category in Category,
            join: user in assoc(category, :users),
            where: category.id == ^category_id and user.archival == false,
            group_by: [user.course, user.group_name],
            order_by: [user.course, user.group_name],
            select:   %{"course" => user.course, "group_name" => user.group_name, "count_students" => count(user.course)}
    CampusRepo.all(query)
  end

end
