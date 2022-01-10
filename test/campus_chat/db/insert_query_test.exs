defmodule CampusChat.InsertQueryTest do
  use CampusChat.DataCase

  alias CampusChat.Message

  test "insert message" do
    msg = %Message{
      chat_id: 1,
      date: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
      sender_id: 1,
      text: "Test Text",
      test_field: "string"
    }
    case {_result, _struct} = Repo.insert(msg) do
      {:ok, _struct}    -> assert true
      {:error, _struct} -> assert false
    end
  end
end
