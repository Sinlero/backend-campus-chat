defmodule CampusChat.CampusDbReadTest do
  use CampusChat.DataCase

  alias CampusChat.CampusQuery

  import CampusChat.Fixtures

  test "get user by id" do
    assert CampusQuery.get_user_by_id(valid_user().id).id == valid_user().id
  end

  test "get user by id with categories" do
    assert CampusQuery.get_user_by_id_with_categories(valid_user().id).categories != []
  end

  test "get all users" do
    assert CampusQuery.get_all_users() != []
  end

  test "get all categories" do
    assert CampusQuery.get_all_categories() != []
  end

  test "get category by id with users" do
    assert CampusQuery.get_users_by_category(valid_category()) != []
  end

  test "get users by selected group" do
    result = CampusQuery.get_users_by_group(valid_category(), valid_user().course, valid_user().group_name).users |> Enum.count()
    assert result == valid_count_students_in_4A()
  end

  test "get list of groups and courses by category" do
    result = CampusQuery.get_list_of_groups_and_courses(valid_category())
    |> Enum.count()
    assert result == valid_count_groups_in_FMF()
  end

  test "get user by login and password" do
    result = CampusQuery.get_user_by_login_and_password(valid_user().login, valid_user().password)
    assert result.id == valid_user().id
  end

end
