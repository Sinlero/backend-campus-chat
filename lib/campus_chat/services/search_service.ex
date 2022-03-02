defmodule CampusChat.SearchService do

  alias CampusChat.Category
  alias CampusChat.CampusQuery
  import CampusChat.ResponseFormatter, only: [delete_unused_categories: 1]

  def get_all_categories() do
    CampusQuery.get_all_categories
    |> Enum.map(fn category -> Category.transfer_cast(category) end)
    |> delete_unused_categories()
  end

  def get_groups(category_id) do
    list = CampusQuery.get_list_of_groups_and_courses(category_id)
    non_groups = list |> Enum.count(fn %{"count_students" => _count, "course" => course, "group_name" => _group} -> course == nil end)
    if non_groups > 0 do
      %{"course" => nil}
    else
      list
    end
  end

  def get_users(category_id, course, group) do
    CampusQuery.get_users_by_group(category_id, course, group).users
  end

  def get_users_by_category(category_id) do
    CampusQuery.get_users_by_category(category_id).users
  end

end
