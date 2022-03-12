defmodule CampusChatWeb.SessionController do
  use CampusChatWeb, :controller
  use PhoenixSwagger

  alias CampusChat.CampusQuery
  alias CampusChat.AuthenticationService
  alias CampusChatWeb.SwaggerParameters

  swagger_path :create do
    post "/login"
    description "Authorization"
    parameter("Credentials", :body, :string, "Campus user login and password", required: true)
  end

  def create(conn, _params) do
    with {login, password} <- Plug.BasicAuth.parse_basic_auth(conn),
           %CampusChat.User{} = user <- CampusQuery.get_user_by_login_and_password(login, password) do
          AuthenticationService.log_in_user(conn, user, %{login: login, password: password})
    else
      _ -> conn |> send_resp(403, "Forbidden") |> halt()
    end
  end

  def echo_me(conn, _params) do
    IO.inspect(conn.assigns)
    json(conn, %{answer: "Echo"})
  end

  swagger_path :get_token do
    get "/token"
    description "Get user token for phoenix channels"
    SwaggerParameters.authorization()
  end

  def get_token(conn, _params) do
    text(conn, conn.assigns[:user_token])
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete "/login"
    description "Logout user"
    SwaggerParameters.authorization()
  end

  def delete(conn, _params) do
    conn
    |> AuthenticationService.log_out_user()
  end

end
