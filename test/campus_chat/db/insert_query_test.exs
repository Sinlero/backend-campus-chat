defmodule CampusChat.InsertQueryTest do
  use CampusChat.DataCase

  alias CampusChat.Message

  describe "insert/read message" do

    test "insert message" do
      case insertMessageQuery() do
        {:ok, _struct}    -> assert true
        {:error, _changeset} -> assert false
      end
    end

    test "read message" do
      {:ok, msg} = insertMessageQuery()
      assert msg.id == Repo.get(Message, msg.id).id
    end

    defp insertMessageQuery() do
      msg = %Message{
        chat_id: 1,
        date: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
        sender_id: 1,
        text: "Test Text",
        test_field: "string"
      }
      Repo.insert(msg)
    end

  end

end
