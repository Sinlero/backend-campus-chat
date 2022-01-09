defmodule CampusChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CampusChat.Repo,
      CampusChat.CampusRepo,
      # Start the Telemetry supervisor
      CampusChatWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CampusChat.PubSub},
      # Start the Endpoint (http/https)
      CampusChatWeb.Endpoint
      # Start a worker by calling: CampusChat.Worker.start_link(arg)
      # {CampusChat.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CampusChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CampusChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
