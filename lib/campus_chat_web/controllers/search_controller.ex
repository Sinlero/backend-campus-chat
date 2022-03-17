defmodule CampusChatWeb.SearchController do
  use CampusChatWeb, :controller
  use PhoenixSwagger

  alias CampusChat.SearchService
  alias CampusChatWeb.SwaggerParameters

  def swagger_definitions do
    %{
      User: swagger_schema do
        title "User"
        description "A user of the chat"
        properties do
          id          :integer
          name        :string
          surname     :string
          patronymic  :string
          description :string
          course      :integer
          group_name  :string
          active      :boolean
          archival    :boolean
          valid_photo :boolean
          photo       :string
        end
        example %{
          id:           999,
          name:        "Иван",
          surname:     "Иванов",
          patronymic:  "Ивнович",
          description: "ФМФ 4А",
          course:       4,
          group_name:  "А",
          active:       true,
          archival:     false,
          valid_photo:  true,
          photo:       "base64image"
        }
      end,
      Users: swagger_schema do
        title "Users"
        description "A collection of Users"
        type :array
        items Schema.ref(:User)
      end,
      Category: swagger_schema do
        title "Category"
        description "Category of users"
        properties do
          id   :integer
          name :string
          type :string
        end
        example %{
          id:    99,
          name: "Импортозамещательный факультет",
          type: "ENTRANT"
        }
      end,
      Categories: swagger_schema do
        title "Categories"
        description "A collection of Categories"
        type :array
        items Schema.ref(:Category)
      end,
      Group: swagger_schema do
        title "Group"
        description "Group with course"
        properties do
          course         :integer
          group_name     :string
          count_students :integer
        end
        example %{
          course:         4,
          group_name:    "А",
          count_students: 15
        }
      end,
      Groups: swagger_schema do
        title "Groups"
        description "A collection of groups"
        type :array
        items Schema.ref(:Group)
      end
    }
  end


  swagger_path :categories do
    get "/categories"
    description "List of categories"
    SwaggerParameters.authorization()
    response 200, "OK", Schema.ref(:Categories)
  end

  def categories(conn, _params) do
    json(conn, SearchService.get_all_categories())
  end

  swagger_path :groups do
    get "/category/{id}"
    description "List of groups with course"
    SwaggerParameters.authorization()
    parameters do
      id :path, :integer, "category id", required: true, example: "99"
    end
    response 200, "Success", Schema.ref(:Groups)
    response 204, "Category have no groups"
    response 404, "Requested category not found"
  end

  def groups(conn, %{"id" => category_id}) do
    result = SearchService.get_groups(category_id)
    case result do
      {:error, _list} -> send_resp(conn, 204, "")                                |> halt()
      {:ok, []}       -> send_resp(conn, 404, "Category with this id not found") |> halt()
      {:ok, list}     -> json(conn, list)                                        |> halt()
    end
  end

  swagger_path :users_of_category do
    get "/users/category/{id}"
    description "List of users by selected category"
    SwaggerParameters.authorization()
    parameters do
      id :path, :integer, "category id", required: true, example: "99"
    end
    response 200, "OK", Schema.ref(:Users)
  end

  def users_of_category(conn, %{"id" => category_id}) do
    json(conn, SearchService.get_users(category_id))
  end

  swagger_path :users_of_group_and_course do
    get "/users/category/{id}/course/{course}/group/{group}"
    description "List of users by selected category, course and group"
    SwaggerParameters.authorization()
    parameters do
      id     :path, :integer, "category id", required: true, example: "99"
      course :path, :integer, "course",      required: true, example: "4"
      group  :path, :string,  "group name",  required: true, example: "А"
    end
    response 200, "OK", Schema.ref(:Users)
  end

  def users_of_group_and_course(conn, %{"id" => category_id, "course" => course, "group" => group}) do
    json(conn, SearchService.get_users(category_id, course, group))
  end

end
