defmodule CampusChatWeb.ChatControllerTest do
  use CampusChatWeb.ConnCase

  import CampusChat.Fixtures

  def logined_session() do
    conn = build_conn() |> Plug.Conn.put_req_header("authorization", "Basic #{base64_credentials()}")
    post(conn, "/api/login")
  end

  test "create dialog with two users" do
    resp = logined_session() |> post("#{api_prefix()}/chat/dialog", %{"first" => 1652, "second" => 1991}) |> json_response(200)
    case resp do
      %{"id" => _value} -> assert true
      _ -> assert false
    end
  end

  test "create dialog with unexisted users" do
    resp = logined_session() |> post("#{api_prefix()}/chat/dialog", %{"first" => -1, "second" => -2}) |> response(404)
    assert resp =~ "User does not exist"
  end

  test "create chat group" do
    body = %{
      "id" => valid_user().id,
      "users" => valid_ids_for_chat(),
      "name" => "Test chat group name"
    }
    resp = logined_session() |> post("#{api_prefix()}/chat/group", body) |> json_response(200)
    case resp do
      %{"id" => _value} -> assert true
      _ -> assert false
    end
  end

end
