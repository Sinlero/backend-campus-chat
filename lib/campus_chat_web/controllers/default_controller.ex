defmodule CampusChatWeb.DefaultController do
  use CampusChatWeb, :controller

  def default(conn, _params) do
    text(conn, "Hello World")
  end

end
