import Config

config :customer_jwt, cowboy_port: (System.get_env("PORT") || "8080") |> String.to_integer
config :customer_jwt, shared_secret: System.get_env("SHARED_SECRET")
config :customer_jwt, validity_in_seconds: (System.get_env("VALIDITY_IN_SECONDS") || "60") |> String.to_integer
