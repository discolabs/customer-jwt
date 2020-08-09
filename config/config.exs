use Mix.Config

config :customer_jwt, cowboy_port: 8080
config :customer_jwt, shared_secret: nil
config :customer_jwt, validity_in_seconds: 60

import_config "#{Mix.env()}.exs"
