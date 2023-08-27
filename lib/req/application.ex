defmodule Req.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ReqWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Req.PubSub},
      # Start Finch
      {Finch, name: Req.Finch},
      # Start the Endpoint (http/https)
      ReqWeb.Endpoint
      # Start a worker by calling: Req.Worker.start_link(arg)
      # {Req.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Req.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ReqWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
