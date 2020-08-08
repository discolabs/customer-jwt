use Mix.Config

config :customer_jwt, cowboy_port: 8080
config :customer_jwt, shared_secret: nil

import_config "#{Mix.env()}.exs"
