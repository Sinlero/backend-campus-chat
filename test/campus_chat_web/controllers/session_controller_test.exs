defmodule CampusChatWeb.SessionControllerTest do
  use CampusChatWeb.ConnCase

  import CampusChat.Fixtures

  test "login" do
    conn = post(build_conn(), "/api/login", [login: valid_user().login, password: valid_user().password])
    assert conn.resp_body =~ "loggined"
  end

  test "wrong login and password" do
    conn = post(build_conn(), "/api/login", [login: "not_exists_login", password: "not_exists_password"])
    assert conn.resp_body =~ "UNAUTHORIZED"
  end

  test "cookie value" do
    conn = post(build_conn(), "/api/login", [login: valid_user().login, password: valid_user().password])
    %{"campus_chat_key" => cookie_value} = conn.cookies
    assert cookie_value != nil
  end

  test "get token" do
    conn = post(build_conn(), "/api/login", [login: valid_user().login, password: valid_user().password])
    |> get("/api/token")
    assert conn.resp_body =~ "SFMyNTY"
  end

  test "token session" do
    alias CampusChat.UserAuth
    token_value =
    post(build_conn(), "/api/login", [login: valid_user().login, password: valid_user().password])
    |> UserAuth.fetch_current_user("params")
    |> get_session(:user_token)
    assert valid_user().id == UserAuth.get_user_by_session_token(token_value).id
  end

end
