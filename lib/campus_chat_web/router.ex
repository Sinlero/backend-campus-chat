defmodule CampusChatWeb.Router do
  use CampusChatWeb, :router

  import CampusChat.AuthenticationService

  @api_prefix Application.get_env(:campus_chat, :api_prefix)

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :put_user_token
  end

  scope @api_prefix, CampusChatWeb do
    pipe_through :api
    post   "/login",  SessionController, :create
    delete "/login",  SessionController, :delete
    get    "/echo",   SessionController, :echo_me
  end

  scope @api_prefix, CampusChatWeb do
    pipe_through [:api, :require_authenticated_user]
    get "/token",                                          SessionController, :get_token
    get "/categories",                                     SearchController,  :categories
    get "/category/:id",                                   SearchController,  :groups
    get "/users/category/:id/course/:course/group/:group", SearchController,  :users_of_group_and_course
    get "/users/category/:id",                             SearchController,  :users_of_category
  end

  scope "#{@api_prefix}/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :campus_chat, swagger_file: "swagger.json"
  end

  def swagger_info() do
    %{
      basePath: "#{@api_prefix}",
      info: %{
        version: "1.0",
        title: "Campus chat"
      },
      securityDefinitions: %{
        credentials: %{
          type: "basic",
          in: "body",
          name: "Authorization"
        }
      },
      consumes: ["application/json"],
      produces: ["application/json"]
    }
  end

  def api_prefix() do
    @api_prefix
  end

  # Putting user token to connection assign
  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end
  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: CampusChatWeb.Telemetry
    end
  end
end
