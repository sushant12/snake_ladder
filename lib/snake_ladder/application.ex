defmodule SnakeLadder.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SnakeLadderWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SnakeLadder.PubSub},
      # Start the Endpoint (http/https)
      SnakeLadderWeb.Endpoint,
      # Start a worker by calling: SnakeLadder.Worker.start_link(arg)
      # {SnakeLadder.Worker, arg}
      SnakeLadderWeb.Presence,
      {Registry, keys: :unique, name: SnakeLadder.GameRegistry},
      SnakeLadder.GameSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SnakeLadder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SnakeLadderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
