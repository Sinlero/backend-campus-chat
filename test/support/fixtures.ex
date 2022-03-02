defmodule CampusChat.Fixtures do

  @category_id 8
  @count_students_in_4A 15
  @count_groups_in_FMF 18
  @mip_id 9
  @count_users_in_mip 8
  @api_prefix Application.get_env(:campus_chat, :api_prefix)

  @valid_user %{
    course: 4,
    description: "ФМФ 4А",
    group_name: "А",
    id: 1652,
    login: "login",
    name: "Андрей",
    password: "password",
    patronymic: "Викторович",
    surname: "Щеголь"
  }

  def valid_user() do
    @valid_user
  end

  def valid_category() do
    @category_id
  end

  def valid_count_students_in_4A() do
    @count_students_in_4A
  end

  def valid_count_groups_in_FMF() do
    @count_groups_in_FMF
  end

  def valid_count_users_in_mip() do
    @count_users_in_mip
  end

  def api_prefix() do
    @api_prefix
  end

  def mip_id() do
    @mip_id
  end
end
