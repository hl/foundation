defmodule Foundation.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FoundationWeb.Telemetry,
      # Start the Ecto repository
      Foundation.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Foundation.PubSub},
      # Start Finch
      {Finch, name: Foundation.Finch},
      # Start the Endpoint (http/https)
      FoundationWeb.Endpoint
      # Start a worker by calling: Foundation.Worker.start_link(arg)
      # {Foundation.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Foundation.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FoundationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
