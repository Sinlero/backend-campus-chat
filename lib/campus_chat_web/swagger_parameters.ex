defmodule CampusChatWeb.SwaggerParameters do
  @moduledoc "Common parameter declarations for phoenix swagger"

  alias PhoenixSwagger.Path.PathObject
  import PhoenixSwagger.Path

  def authorization(path = %PathObject{}) do
    path
    |> security([%{credentials: []}])
  end

end
