defmodule CampusChat.CampusDbReadTest do
  use CampusChat.DataCase

  alias CampusChat.CampusRepo

  test "read user from campus by id" do
    query = from user in "users",
              where: user.id == 1652,
              select: {user.id, user.name, user.surname, user.patronymic,
              user.login, user.password, user.description, user.course, user.group_name}
    assert [] != CampusRepo.all(query)
  end

end
