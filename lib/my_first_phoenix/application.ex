defmodule MyFirstPhoenix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MyFirstPhoenixWeb.Telemetry,
      # Start the Ecto repository
      MyFirstPhoenix.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: MyFirstPhoenix.PubSub},
      # Start Finch
      {Finch, name: MyFirstPhoenix.Finch},
      # Start the Endpoint (http/https)
      MyFirstPhoenixWeb.Endpoint,
      # Start a worker by calling: MyFirstPhoenix.Worker.start_link(arg)
      # {MyFirstPhoenix.Worker, arg}

      MyFirstPhoenix.Tictactoe.Server
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyFirstPhoenix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MyFirstPhoenixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
