defmodule CustomerJwtTest do
  use ExUnit.Case
  doctest CustomerJwt

  test "greets the world" do
    assert CustomerJwt.hello() == :world
  end
end
