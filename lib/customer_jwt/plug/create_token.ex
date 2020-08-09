defmodule CustomerJwt.Plug.CreateToken do
  import Plug.Conn

  require Logger

  defmodule MissingShopError do
    @moduledoc """
    Error raised when no shop is provided.
    """

    defexception message: "Missing shop", plug_status: 400
  end

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
    query_params = conn.query_params

    if path in options[:paths] do
      verify_parameters!(query_params)
      generate_response(conn, query_params)
    else
      conn
    end
  end

  defp verify_parameters!(query_params) do
    Logger.info("---> provided shop #{query_params["shop"]}")
    Logger.info("---> provided customer #{query_params["customer_id"]}")

    unless query_params["shop"] != nil, do: raise(MissingShopError)
    unless query_params["customer_id"] != nil, do: raise(MissingCustomerError)
  end

  defp generate_response(conn, query_params) do
    conn
    |> put_resp_content_type("application/liquid")
    |> send_resp(200, generate_token(query_params))
  end

  defp generate_token(query_params) do
    customer_id = Integer.parse(query_params["customer_id"])
    shopify_domain = query_params["shop"]

    {:ok, token, claims} = CustomerJwt.Token.generate_and_sign_for_customer(customer_id, shopify_domain)

    token
  end

end
