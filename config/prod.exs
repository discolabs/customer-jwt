use Mix.Config

config :customer_jwt, cowboy_port: String.to_integer(System.get_env("PORT"))
config :customer_jwt, shared_secret: System.get_env("SHARED_SECRET")
config :customer_jwt, validity_in_seconds: String.to_integer(System.get_env("VALIDITY_IN_SECONDS"))

import_config "#{Mix.env()}.exs"
