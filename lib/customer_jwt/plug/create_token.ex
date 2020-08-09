defmodule CustomerJwt.Plug.CreateToken do
  import Plug.Conn

  require Logger

  defmodule MissingCustomerError do
    @moduledoc """
    Error raised when no customer is provided.
    """

    defexception message: "Missing customer", plug_status: 400
  end

  def init(options) do
    unless options[:paths], do: raise(ArgumentError, message: "missing required argument :paths")

    options
  end

  def call(%Plug.Conn{request_path: path} = conn, options) do
    conn = Plug.Conn.fetch_query_params(conn)

    if path in options[:paths] do
      verify_parameters!(conn.query_params)
      generate_token(conn)
    else
      conn
    end
  end

  defp verify_parameters!(query_params) do
    Logger.info("---> provided customer #{query_params["customer_id"]}")

    unless query_params["customer_id"] != nil do
      raise(MissingCustomerError)
    end
  end

  defp generate_token(conn) do
    conn
    |> put_resp_content_type("application/liquid")
    |> send_resp(200, "123.456.789")
  end

end
