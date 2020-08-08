defmodule CustomerJwt.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias CustomerJwt.Router

  @opts Router.init([])

  test "unknown endpoint returns 404" do
    conn = conn(:get, "/404")
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  test "token endpoint raises missing signature error when no signature provided" do
    assert_raise CustomerJwt.Plug.VerifyAppProxyRequest.MissingSignatureError, fn ->
      conn = conn(:get, "/token")
      Router.call(conn, @opts)
    end
  end

  test "token endpoint raises invalid signature error when invalid signature provided" do
    assert_raise CustomerJwt.Plug.VerifyAppProxyRequest.InvalidSignatureError, fn ->
      conn = conn(:get, "/token", %{customer_id: "3041789640759", signature: "invalid"})
      Router.call(conn, @opts)
    end
  end

  test "token endpoint returns jwt when customer id and valid signature provided" do
    conn = conn(:get, "/token", %{customer_id: "3041789640759", signature: "816cb937a21250cc9353982f3dc1187b53c566428bd701652efc4c3ab178ac3b"})
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

end
