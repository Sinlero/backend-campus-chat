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
    CampusQuery.get_list_of_groups_and_courses(category_id)
  end
end
