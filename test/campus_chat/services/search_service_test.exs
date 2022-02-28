defmodule CampusChat.SearchServiceTest do
  use CampusChat.DataCase

  import CampusChat.Fixtures

  alias CampusChat.ResponseFormatter
  alias CampusChat.CampusQuery
  alias CampusChat.Category

  test "delete unused categories" do
    unused = Application.get_env(:campus_chat, :unused_categories)
    result = CampusQuery.get_all_categories
    |> Enum.map(fn category -> Category.transfer_cast(category) end)
    |> ResponseFormatter.delete_unused_categories()
    |> Enum.map(fn category -> category.name end)
    assert Enum.any?(result, fn category -> category in unused end) == false
  end

  test "get list of groups and courses" do
    assert CampusChat.SearchService.get_groups(valid_category()) |> Enum.count() == valid_count_groups_in_FMF()
  end

end
