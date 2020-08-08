defmodule CustomerJwt.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/token" do
    send_resp(conn, 200, "Token")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
