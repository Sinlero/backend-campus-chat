defmodule CampusChat.SearchService do

  alias CampusChat.Category
  alias CampusChat.CampusQuery
  import CampusChat.ResponseFormatter, only: [deleteTestRecords: 1]

  def getAllCategories() do
    CampusQuery.get_all_categories
    |> Enum.map(fn category -> Category.transfer_cast(category) end)
    |> deleteTestRecords()
  end
end
