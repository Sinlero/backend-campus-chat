defmodule CampusChatWeb.SessionController do
  use CampusChatWeb, :controller

  alias CampusChat.CampusQuery
  alias CampusChat.UserAuth

  def create(conn, %{"login" => login, "password" => password}) do
    user_params = %{login: login, password: password}
    if user = CampusQuery.get_user_by_login_and_password(login, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      send_resp(conn, 401, "UNAUTHORIZED")
      |> halt()
    end

  end

  def echo_me(conn, _params) do
    IO.inspect(conn.assigns)
    json(conn, %{answer: "Echo"})
  end

  def get_token(conn, _params) do
    text(conn, conn.assigns[:user_token])
  end

  def delete(conn, _params) do
    conn
    |> UserAuth.log_out_user()
  end

end
