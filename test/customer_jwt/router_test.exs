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

  test "token endpoint raises missing customer error when no customer provided" do
    assert_raise CustomerJwt.Plug.CreateToken.MissingCustomerError, fn ->
      conn = conn(:get, "/token", %{signature: "b4f2fae23b2660cfb46cc27563740b4d1771e6dd0a3e9d5c19dc027a87768377"})
      Router.call(conn, @opts)
    end
  end

  test "token endpoint returns jwt when customer id and valid signature provided" do
    conn = conn(:get, "/token", %{customer_id: "3041789640759", signature: "816cb937a21250cc9353982f3dc1187b53c566428bd701652efc4c3ab178ac3b"})
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "{% if customer.id == 3041789640759 %}eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGVzaG9wLm15c2hvcGlmeS5jb20vYWRtaW4iLCJkZXN0IjoiaHR0cHM6Ly9leGFtcGxlc2hvcC5teXNob3BpZnkuY29tIiwiYXVkIjoiYXBpLWtleS0xMjMiLCJzdWIiOjMwNDE3ODk2NDA3NTksImV4cCI6MTU5MTc2NTA1OCwibmJmIjoxNTkxNzY0OTk4LCJpYXQiOjE1OTE3NjQ5OTgsImp0aSI6ImY4OTEyMTI5LTFhZjYtNGNhZC05Y2EzLTc2YjBmNzYyMTA4NyJ9.9N9jPXJHD0kNaE3S_-oEcrWpsk9FMSqWt7HzbbA_Ifw{% endif %}"
  end

end
