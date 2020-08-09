defmodule JokenStub do
  @moduledoc """
  Stubs the two dynamic methods used by Joken to generate JWT tokens, so that
  we have reproducible tests when running our controller tests.

  The use of this stub is controller by the customer_jwt.jti_generator
  configuration value, which defaults to the Joken module but is set to
  JokenStub in test.
  """

  def current_time do
    1591764998
  end

  def generate_jti do
    "2okohaiag8hi1nt2vs000051"
  end
end

ExUnit.start()
