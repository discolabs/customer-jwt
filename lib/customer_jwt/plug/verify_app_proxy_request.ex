defmodule CustomerJwt.Plug.VerifyAppProxyRequest do

  require Logger

  defmodule MissingSignatureError do
    @moduledoc """
    Error raised when no signature is provided.
    """

    defexception message: ""
  end

  defmodule InvalidSignatureError do
    @moduledoc """
    Error raised when the provided signature is invalid.
    """

    defexception message: ""
  end

  def init(options) do
    unless options[:paths], do: raise(ArgumentError, message: "missing required argument :paths")
    unless options[:shared_secret], do: raise(ArgumentError, message: "missing required argument :shared_secret")

    options
  end

  def call(%Plug.Conn{ request_path: path } = conn, options) do
    conn = Plug.Conn.fetch_query_params(conn)

    if path in options[:paths], do: verify_signature!(conn.query_params, options[:shared_secret])

    conn
  end

  defp verify_signature!(query_params, shared_secret) do
    Logger.info("---> provided signature #{query_params["signature"]}")

    unless query_params["signature"] != nil do
      raise(MissingSignatureError)
    end

    calculated_signature = calculate_signature(query_params, shared_secret)

    Logger.info("---> calculated signature #{calculated_signature}")

    unless Plug.Crypto.secure_compare(query_params["signature"], calculated_signature) do
      raise(InvalidSignatureError)
    end
  end

  defp calculate_signature(query_params, shared_secret) do
    query_params
    |> Map.delete("signature")
    |> Enum.sort()
    |> Plug.Conn.Query.encode()
    |> generate_hmac(shared_secret)
    |> Base.encode16()
    |> String.downcase()
  end

  defp generate_hmac(query_hash, shared_secret) do
    :crypto.hmac(:sha256, shared_secret, query_hash)
  end

end
