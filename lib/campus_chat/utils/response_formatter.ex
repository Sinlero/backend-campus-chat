defmodule CampusChat.ResponseFormatter do

  def deleteTestRecords(list_of_categories) do
    index = Enum.find_index(list_of_categories, fn category -> category.name =~ "Тест" end)
    case index do
      nil -> list_of_categories
      _   -> List.delete_at(list_of_categories, index) |> deleteTestRecords()
    end
  end

end
