defmodule CampusChat.CampusDbReadTest do
  use CampusChat.DataCase

  alias CampusChat.CampusQuery

  @category_id 8
  @count_students_in_4A 16
  @count_groups_in_FMF 22

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

  test "get user by id" do
    assert CampusQuery.get_user_by_id(@valid_user.id).id == @valid_user.id
  end

  test "get user by id with categories" do
    assert CampusQuery.get_user_by_id_with_categories(@valid_user.id).categories != []
  end

  test "get all users" do
    assert CampusQuery.get_all_users() != []
  end

  test "get all categories" do
    assert CampusQuery.get_all_categories() != []
  end

  test "get category by id with users" do
    assert CampusQuery.get_users_by_category(@category_id) != []
  end

  test "get users by selected group" do
    result = CampusQuery.get_users_by_group(@category_id, @valid_user.course, @valid_user.group_name).users |> Enum.count()
    assert result == @count_students_in_4A
  end

  test "get list of groups and courses by category" do
    result = CampusQuery.get_list_of_groups_and_courses(@category_id)
    |> Enum.count()
    assert result == @count_groups_in_FMF
  end

  test "get user by login and password" do
    result = CampusQuery.get_user_by_login_and_password(@valid_user.login, @valid_user.password)
    assert result.id == @valid_user.id
  end

end
