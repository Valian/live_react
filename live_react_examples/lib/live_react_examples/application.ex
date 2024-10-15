defmodule LiveReactExamples.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {NodeJS.Supervisor, [path: LiveReact.SSR.NodeJS.server_path(), pool_size: 1]},
      LiveReactExamplesWeb.Telemetry,
      {DNSCluster,
       query: Application.get_env(:live_react_examples, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveReactExamples.PubSub},
      # Start a worker by calling: LiveReactExamples.Worker.start_link(arg)
      # {LiveReactExamples.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveReactExamplesWeb.Endpoint
    ]

    # Set up LiveReactExamples.Telemetry
    LiveReactExamples.Telemetry.setup()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveReactExamples.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveReactExamplesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
