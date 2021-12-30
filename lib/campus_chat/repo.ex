defmodule CampusChat.Repo do
  use Ecto.Repo,
    otp_app: :campus_chat,
    adapter: Ecto.Adapters.Postgres
end
