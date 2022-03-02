defmodule CampusChatWeb.SearchController do
  use CampusChatWeb, :controller

  alias CampusChat.SearchService

  def categories(conn, _params) do
    json(conn, SearchService.get_all_categories())
  end

  def groups(conn, %{"id" => category_id}) do
    json(conn, SearchService.get_groups(category_id))
  end

  def users_of_category(conn, %{"id" => category_id}) do
    json(conn, SearchService.get_users(category_id))
  end

  def users_of_group_and_course(conn, %{"id" => category_id, "course" => course, "group" => group}) do
    json(conn, SearchService.get_users(category_id, course, group))
  end

end
