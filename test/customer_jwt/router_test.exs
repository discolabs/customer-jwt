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
      conn = conn(:get, "/token", %{customer_id: "3041789640759", timestamp: "1591764998", signature: "df2f8fa97610b21a12df58394308944be5776bc0caabfd7ec130ab8510c0832d"})
      Router.call(conn, @opts)
    end
  end

  test "token endpoint raises missing customer error when no customer provided" do
    assert_raise CustomerJwt.Plug.CreateToken.MissingCustomerError, fn ->
      conn = conn(:get, "/token", %{shop: "examplestore.myshopify.com", timestamp: "1591764998", signature: "5f8a7472e2e124ef0f1f82365ad247c5da59aa53aa3181c549bfab63c8abeec5"})
      Router.call(conn, @opts)
    end
  end

  test "token endpoint raises missing timestamp error when no timestamp provided" do
    assert_raise CustomerJwt.Plug.CreateToken.MissingTimestampError, fn ->
      conn = conn(:get, "/token", %{shop: "examplestore.myshopify.com", customer_id: "3041789640759", signature: "73d4be1acac3973d50ff93f0183a7b01496552b76da7b26ab98b4efabf10dd67"})
      Router.call(conn, @opts)
    end
  end

  test "token endpoint returns expected jwt when shop, customer, timestamp and valid signature provided" do
    conn = conn(:get, "/token", %{shop: "examplestore.myshopify.com", customer_id: "3041789640759", timestamp: "1591764998", signature: "ab88c034e1149a93d02cc355abfea9ac4b46975248689817ba2d30fca19ab5e6"})
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "{% if customer.id == 3041789640759 %}eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIqIiwiZGVzdCI6Imh0dHBzOi8vZXhhbXBsZXN0b3JlLm15c2hvcGlmeS5jb20iLCJleHAiOjE1OTE3NjUwNTgsImlhdCI6MTU5MTc2NDk5OCwiaXNzIjoiaHR0cHM6Ly9leGFtcGxlc3RvcmUubXlzaG9waWZ5LmNvbS9hZG1pbiIsImp0aSI6IjJva29oYWlhZzhoaTFudDJ2czAwMDA1MSIsIm5iZiI6MTU5MTc2NDk5OCwic3ViIjozMDQxNzg5NjQwNzU5fQ.Nf59mhgjyO2G9VPPiKm6risGZg7uTfsziUSCmOU0VSg{% endif %}"
  end

end
