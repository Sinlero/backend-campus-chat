defmodule CampusChat.CampusDbReadTest do
  use CampusChat.DataCase

  alias CampusChat.CampusRepo
  alias CampusChat.User
  alias CampusChat.Category
  alias CampusChat.CampusQuery

  @valid_user %{
    course: 4,
    description: "ФМФ 4А",
    group_name: "А",
    id: 1652,
    login: "login",
    name: "Андрей",
    password: "password",
    patronymic: "Викторович",
    surname: "Щеголь"
  }

  test "read user from campus by id" do
    id = 1652
    assert CampusQuery.getUserById(id) == @valid_user
  end

  test "read all users" do
    assert [] != CampusQuery.getAllUsers()
  end

  test "get all categories" do
    assert [] != CampusQuery.getAllCategories()
  end

  test "get users on selected category" do
    category_id = 8 # ФМФ
    assert [] != CampusQuery.getUsersByCategory(category_id)
  end

  test "get list of groups and courses by category" do
    category_id = 8 # ФМФ
    assert [] != CampusQuery.getListOfGroupsAndCourses(category_id)
  end

  test "get users on selected group" do
    category_id = 8 # ФМФ
    course = 4
    group = "А"
    assert [] != CampusQuery.getUsersByGroup(category_id, course, group)
  end

  test "get user by id (with schema)" do
    user = CampusRepo.get(User, @valid_user.id)
    IO.inspect(user)
  end

  test "get all categories (with schema)" do
    query = from category in Category,
            select: category
    assert [] != CampusRepo.all(query)
    # |> IO.inspect()
  end

  test "get category by id with users (with schema)" do
    category_id = 8
    CampusRepo.get(Category, category_id)
    |> CampusRepo.preload([:users])
    |> IO.inspect()
  end

end
