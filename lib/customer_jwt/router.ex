defmodule CustomerJwt.Router do
  use Plug.Router
  use Plug.ErrorHandler

  alias CustomerJwt.Plug.VerifyAppProxyRequest

  plug Plug.Logger
  plug VerifyAppProxyRequest, paths: ["/token"], shared_secret: Application.get_env(:customer_jwt, :shared_secret)
  plug :match
  plug :dispatch

  get "/token" do
    send_resp(conn, 200, "{token}")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp handle_errors(conn, %{reason: reason}) do
    send_resp(conn, conn.status, reason.message)
  end
end
