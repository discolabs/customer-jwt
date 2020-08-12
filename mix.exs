defmodule CustomerJwt.MixProject do
  use Mix.Project

  def project do
    [
      app: :customer_jwt,
      version: "0.1.4",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CustomerJwt.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:joken, "~> 2.0"},
      {:jason, "~> 1.1"}
    ]
  end
end
