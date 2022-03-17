defmodule CampusChatWeb.SearchControllerTest do
  use CampusChatWeb.ConnCase

  import CampusChat.Fixtures

  def logined_session() do
    conn = build_conn() |> Plug.Conn.put_req_header("authorization", "Basic #{base64_credentials()}")
    post(conn, "/api/login")
  end

  test "get all categories" do
    conn = logined_session() |> get("#{api_prefix()}/categories")
    assert conn.resp_body != nil
  end

  test "get groups and courses by category" do
    response = logined_session() |> get("#{api_prefix()}/category/#{valid_category()}") |> json_response(200)
    assert response == CampusChat.SearchService.get_groups(valid_category())
  end

  test "get users of group and course" do
    response_count_students =
      logined_session()
      |> get("#{api_prefix()}/users/category/#{valid_category()}/course/#{valid_user().course}/group/#{valid_user().group_name}")
      |> json_response(200)
      |> Enum.count()
    assert response_count_students == valid_count_students_in_4A()
  end

  test "get users of category" do
    response_count_users =
      logined_session()
      |> get("#{api_prefix()}/users/category/#{mip_id()}")
      |> json_response(200)
      |> Enum.count()
    assert response_count_users == valid_count_users_in_mip()
  end
end
