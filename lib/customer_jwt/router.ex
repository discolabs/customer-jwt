defmodule CustomerJwt.Router do
  use Plug.Router

  alias CustomerJwt.Plug.VerifyAppProxyRequest

  plug VerifyAppProxyRequest, paths: ["/token"], shared_secret: Application.get_env(:customer_jwt, :shared_secret)
  plug :match
  plug :dispatch

  get "/token" do
    send_resp(conn, 200, "Token")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
