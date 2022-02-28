defmodule CampusChatWeb.SearchControllerTest do
  use CampusChatWeb.ConnCase

  import CampusChat.Fixtures

  def logined_session() do
    post(build_conn(), "/api/login", [login: valid_user().login, password: valid_user().password])
  end

  test "get all categories" do
    conn = logined_session() |> get("/api/categories")
    assert conn.resp_body != nil
  end

  test "get groups and courses by category" do
    response = logined_session() |> get("/api/category/#{valid_category()}") |> json_response(200)
    assert response == CampusChat.SearchService.get_groups(valid_category())
  end
end
