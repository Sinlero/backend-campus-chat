defmodule CampusChat.CampusRepo do
  use Ecto.Repo,
    otp_app: :campus_chat,
    adapter: Ecto.Adapters.Postgres,
    read_only: true
end
