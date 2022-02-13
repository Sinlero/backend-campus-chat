defmodule CampusChatWeb.Router do
  use CampusChatWeb, :router

  import CampusChat.UserAuth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    # plug :fetch_live_flash
    # plug :protect_from_forge
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :put_user_token
  end

  scope "/api", CampusChatWeb do
    pipe_through :api
    post   "/login",  SessionController, :create
    delete "/login",  SessionController, :delete
    get    "/echo",   SessionController, :echo_me
    get    "/token",  SessionController, :get_token
  end

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
