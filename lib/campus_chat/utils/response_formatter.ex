defmodule CampusChat.ResponseFormatter do

  def delete_unused_categories(list_of_categories) do
    index = Enum.find_index(list_of_categories, fn category -> unused_category?(category) end)
    case index do
      nil -> list_of_categories
      _   -> List.delete_at(list_of_categories, index) |> delete_unused_categories()
    end
  end

  defp unused_category?(category) do
    Application.get_env(:campus_chat, :unused_categories)
    |> Enum.any?(fn unused_category -> category.name == unused_category end)
  end

end
