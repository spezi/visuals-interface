defmodule VisualsAdmin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VisualsAdminWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:visuals_admin, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: VisualsAdmin.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: VisualsAdmin.Finch},
      # Start a worker by calling: VisualsAdmin.Worker.start_link(arg)
      # {VisualsAdmin.Worker, arg},
      # Start to serve requests, typically the last entry
      VisualsAdminWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VisualsAdmin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VisualsAdminWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
