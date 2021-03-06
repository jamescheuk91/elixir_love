defmodule ElixirLove.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ElixirLove.CodeSession

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ElixirLoveWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ElixirLove.PubSub},
      # Start the Endpoint (http/https)
      ElixirLoveWeb.Endpoint,
      # Start a worker by calling: ElixirLove.Worker.start_link(arg)
      # {ElixirLove.Worker, arg}
      {Registry, keys: :unique, name: CodeSession.Registry},
      {CodeSession.Counter, name: CodeSession.Counter},
      {DynamicSupervisor, name: CodeSession.DynamicSupervisor, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirLove.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ElixirLoveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
