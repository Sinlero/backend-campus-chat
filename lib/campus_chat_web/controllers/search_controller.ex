defmodule CampusChatWeb.SearchController do
  use CampusChatWeb, :controller

  alias CampusChat.SearchService

  def categories(conn, _params) do
    json(conn, SearchService.get_all_categories())
  end

end
