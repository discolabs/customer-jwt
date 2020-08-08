defmodule CustomerJwt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: CustomerJwt.TokenPlug, options: [port: 8080]}
    ]
    opts = [strategy: :one_for_one, name: CustomerJwt.Supervisor]

    Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end
end
