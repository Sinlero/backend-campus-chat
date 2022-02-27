defmodule CampusChatWeb.SearchController do
  use CampusChatWeb, :controller

  alias CampusChat.SearchService

  def categories(conn, _params) do
    json(conn, SearchService.get_all_categories())
  end

  def groups(conn, %{"id" => category_id}) do
    json(conn, SearchService.get_groups(category_id))
  end

end
