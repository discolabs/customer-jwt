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
      conn = conn(:get, "/token", %{shop: "examplestore.myshopify.com", customer_id: "3041789640759", timestamp: "1591764998", signature: "invalid"})
      Router.call(conn, @opts)
    end
  end

  test "token endpoint raises missing shop error when no shop provided" do
    assert_raise CustomerJwt.Plug.CreateToken.MissingShopError, fn ->
      conn = conn(:get, "/token", %{customer_id: "3041789640759", timestamp: "1591764998", signature: "6d87576f1799f712db2a76f4bff0927239835a189203363ee9912f51de3a3fa5"})
      Router.call(conn, @opts)
    end
  end

  test "token endpoint raises missing customer error when no customer provided" do
    assert_raise CustomerJwt.Plug.CreateToken.MissingCustomerError, fn ->
      conn = conn(:get, "/token", %{shop: "examplestore.myshopify.com", timestamp: "1591764998", signature: "63e4c8c85dc022239622c64dc796356a74e3f8e29edda3c96d74530cc739c715"})
      Router.call(conn, @opts)
    end
  end

  test "token endpoint raises missing timestamp error when no timestamp provided" do
    assert_raise CustomerJwt.Plug.CreateToken.MissingTimestampError, fn ->
      conn = conn(:get, "/token", %{shop: "examplestore.myshopify.com", customer_id: "3041789640759", signature: "f7adf74de4f95e3a4f174f3f17abd604da3f2043391dc0009d954a9f5c9e823b"})
      Router.call(conn, @opts)
    end
  end

  test "token endpoint returns expected jwt when shop, customer, timestamp and valid signature provided" do
    conn = conn(:get, "/token", %{shop: "examplestore.myshopify.com", customer_id: "3041789640759", timestamp: "1591764998", signature: "45d8daaeb0f9068ed7a4cbcb8463737efb158770725ff975429f23badcf5d9d4"})
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "{% if customer.id == 3041789640759 %}eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIqIiwiZGVzdCI6Imh0dHBzOi8vZXhhbXBsZXN0b3JlLm15c2hvcGlmeS5jb20iLCJleHAiOjE1OTE3NjUwNTgsImlhdCI6MTU5MTc2NDk5OCwiaXNzIjoiaHR0cHM6Ly9leGFtcGxlc3RvcmUubXlzaG9waWZ5LmNvbS9hZG1pbiIsImp0aSI6IjJva29oYWlhZzhoaTFudDJ2czAwMDA1MSIsIm5iZiI6MTU5MTc2NDk5OCwic3ViIjozMDQxNzg5NjQwNzU5fQ.Nf59mhgjyO2G9VPPiKm6risGZg7uTfsziUSCmOU0VSg{% endif %}"
  end

end
