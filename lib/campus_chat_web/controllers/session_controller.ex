defmodule CampusChatWeb.SessionController do
  use CampusChatWeb, :controller
  use PhoenixSwagger

  alias CampusChat.CampusQuery
  alias CampusChat.AuthenticationService
  alias CampusChatWeb.SwaggerParameters

  def swagger_definitions do
    %{
      Token: swagger_schema do
        title "Token"
        description "A token for phoenix channels"
        property :token, :string, "Token"
        example %{"token" => "SFMyNTY.sopksij45dfgsd89sn5jA23s6eSD"}
      end
    }
  end

  swagger_path :create do
    post "/login"
    description "Authorization"
    parameter("Authorization", :header, :string, "Basic authorization campus user", required: false)
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
    response 200, "success", Schema.ref(:Token)
  end

  def get_token(conn, _params) do
    json(conn, %{"token" => conn.assigns[:user_token]})
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
